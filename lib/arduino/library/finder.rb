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
      class << self
        include ::Arduino::Library::InstanceMethods

        # Finds a given model with only partial data by
        # searching in the Ardiuino Database.
        #
        #      model = Arduino::Library::Finder.find({ name: 'AudioZero'} )
        #      # => <Arduino::Library::Model#0x3242gfa2...>
        #
        #      model.url # => 'https://github.com/.......'
        #
        # @param [Model] model with a partial information only, such as the name.
        # @return [Model] a found model with #url provided, if found, nil otherwise.
        def find(model)
          raise ArgumentError, 'Model argument is required' unless model

          model = Model.from(model) unless model.is_a?(Model)
          return model unless model.partial?

          query = construct_query(model)
          return nil if query.empty?

          latest_version_by(query)
        end

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
        def latest_version_by(query)
          results = if query.key?(:name)
                      Model.find(**query).sort
                    else
                      Model.find(**query)
                    end
          return nil if results.size == 0
          return results.first if results.size == 1
          results.last
        end
      end
    end
  end
end
