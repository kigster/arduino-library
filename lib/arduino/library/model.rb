require_relative 'types'
require_relative 'utilities'
require_relative 'instance_methods'
require_relative 'resolver'
require 'json'

module Arduino
  module Library
    # This class represents a single entry into the library-index.json file,
    # in other words — a `library.properties` file.
    class Model < Dry::Struct
      include Comparable

      # noinspection RubyResolve
      constructor_type :schema

      Types::LIBRARY_PROPERTIES.each_pair do |field, type|
        self.attribute field, eval(type)
      end

      # Instance Methods

      # Convert a version such as '1.44.3' into a number '1044003' for easy
      # sorting and comparison.
      def version_to_i
        if version
          first, second, third = version.split(/\./).map(&:to_i)
          10**6 * (first || 0) + 10**3 * (second || 0) + (third || 0)
        else
          0
        end
      rescue
        0
      end

      def <=>(another)
        self.version_to_i <=> another.version_to_i
      end

      # Class Methods

      class << self
        include Utilities
        include InstanceMethods

        attr_writer :database

        def from_hash(hash)
          new(Types.schema[hash])
        end

        def from_json(json)
          from_hash(JSON.load(json))
        end

        def from_json_file(file_or_url)
          file = read_file_or_url(file_or_url)
          from_json(file.read)
        end

        def from_properties_file(file_or_url)
          raise "File #{file_or_url} does not exist?" unless File.exist?(file_or_url)
          Presenters::Properties.from(file_or_url)
        end

        def database
          @database ||= DefaultDatabase.instance
        end

        def find(**opts)
          database.search(**opts)
        end

        # @param [Object] source — file name or a URL to JSON or .properties file
        #
        # ## Searching
        #
        # #### Database
        #
        # Searching requires a database, which can either be set via
        #
        #       Arduino::Library::Model.database = Database.from(file)
        #
        # otherwise it defaults to the default database, +DefaultDatabase.instance+.
        #
        # @param [Hash] opts   — search parameters to the current database
        #
        # #### Query
        #
        # +opts+ is a Hash that you can use to pass attributes with values, any
        # number of them. All matching results are returned as models from the
        # current database.
        #
        #   name: 'AudioZero'
        #   author: /konstantin/i              - regexp supported
        #   architectures: [ 'avr' ]           - array is matched if it's a subset
        #   version: proc do |value|           — or a proc for max flexibility
        #     value.start_with?('1.') )
        #   ends
        #
        # @return [Model | Array<Model> ] — array for search, otherwise a model
        def from(source = nil, **opts)
          model = case source
                    when Hash
                      from_hash(source)
                    when String
                      if source =~ /^{/m
                        from_json(source)
                      elsif File.exist?(source)
                        if source =~ /\.json(\.gz)?$/i
                          from_json_file(source)
                        elsif source =~ /\.properties(\.gz)?$/i
                          from_properties_file(source)
                        end
                      end
                    when NilClass
                      if opts && opts[:name] && opts[:version]
                        search(**opts)
                      end
                  end
          model ? Resolver.resolve(model) : model
        end
      end
    end
  end
end


require_relative 'presenters/properties'
