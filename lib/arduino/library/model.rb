require_relative 'types'
require_relative 'utilities'
require 'json'

module Arduino
  module Library
    # This class represents a single entry into the library-index.json file,
    # in other words — a `library.properties` file.
    class Model < Dry::Struct

      # noinspection RubyResolve
      constructor_type :symbolized

      Types::LIBRARY_PROPERTIES.each_pair do |field, type|
        self.attribute field, eval(type)
      end

      class << self
        include Utilities

        attr_writer :database

        def from_hash(hash)
          new(Types.schema[hash])
        end

        def from_json(json)
          from_hash(JSON.load(json))
        end

        def from_json_file(file_or_url)
          file  = read_file_or_url(file_or_url)
          from_json(file.read)
        end

        def from_properties_file(file_or_url)
          raise "File #{file_or_url} does not exist?" unless File.exist?(file_or_url)
          Presenters::Properties.from(file_or_url)
        end

        def database
          @database ||= Database.default
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
        # otherwise it defaults to the default database, +Database.default+.
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
          case source
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
        end

      end
    end
  end
end


require_relative 'presenters/properties'
