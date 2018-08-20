require_relative 'instance_methods'
require_relative 'model'

module Arduino
  module Library
    # The goal of this class is to identify a *single* library
    # complete with all the metadata, in particular URL, so that
    # the library can be installed.
    #
    # We accept partial information about the library, and construct
    # query based this information. If multiple entries returned,
    # but for the same library, the latest version is returned.
    module Finder
      module FinderMethods
        # Finds a given model with only partial data by
        # searching in the Arduino Database.
        #
        #      model = Arduino::Library::Finder.find({ name: 'AudioZero'} )
        #      # => <Arduino::Library::Model#0x3242gfa2...>
        #
        #      model.url # => 'https://github.com/.......'
        #
        # @param [Model] model with a partial information only, such as the name.
        # @return [Model] a found model with #url provided, if found, nil otherwise.
        def find_library(model, version: :latest)
          raise ArgumentError, 'Model argument is required' unless model
          model = Model.from(model) unless model.is_a?(Model)
          return model unless model&.partial?

          query = construct_query(model)
          return nil if query.empty?

          get_library_version(query, version: version)
        end

        alias find find_library

        private

        # Given a model with partial information, constructs a query
        # by name and version.
        # @param [Model] model a library model with name, and optionally version
        # @return [Hash] query to be passed to #search. (See Arduino::Library::InstanceMethods#search)
        def construct_query(model)
          query = {}
          query.merge!(name: model.name) if model.name
          query.merge!(version: model.version) if model.version
          query
        end

        # Executes a given query, and if more than one version is returned
        # returns the last most recent version of the library.
        #
        # @param [Hash] query model attributes to search for, eg, +name: 'AudioZero'
        # @return <Model>  search result, or the most recent version if many match
        def get_library_version(query, version: :latest)
          results = if query.key?(:name)
                      Model.find(**query).sort
                    else
                      Model.find(**query)
                    end
          return nil if results.size == 0
          return results.first if results.size == 1

          if version == :latest
            results.last
          elsif version == :oldest
            results.last
          elsif version =~ /^[0-9.]*$/
            results.find { |r| r.version == version }
          else
            raise ArgumentError, "Invalid version specified in arguments — #{version}." +
                "Expecting either :latest, :oldest, or a specific version number."
          end
        end
      end


      class << self
        include ::Arduino::Library::InstanceMethods
        include ::Arduino::Library::Finder::FinderMethods
      end
    end
  end
end
