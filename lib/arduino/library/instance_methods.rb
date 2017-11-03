require 'arduino/library'

module Arduino
  module Library
    module InstanceMethods
      # @param [String] file_or_url — either a local file, or URL, can be gzipped
      def db_from(file_or_url)
        Database.new(file_or_url)
      end

      def db_default
        DefaultDatabase.instance
      end

      #
      # +file_or_url+ can be a JSON file name, a .properties file name, or
      # a URL to either of the above.
      #
      # @param [String] file_or_url
      def library_from(file_or_url)
        Arduino::Library::Model.from(file_or_url)
      end

      # +opts+ is a Hash that you can use to pass attributes with values, any
      # number of them. All matching results are returned as models.
      #
      #   name: 'AudioZero'
      #   author: /konstantin/i              - regexp supported
      #   architectures: [ 'avr' ]           - array is matched if it's a subset
      #   version: proc do |value|           — or a proc for max flexibility
      #     value.start_with?('1.') )
      #   end
      #
      # @param [Database] database db instance (or skip it to use the default)
      # @param [Hash] opts hash of attribute names and values to match
      # @return Array<Model> array of models that match
      def search(database = db_default, **opts)
        Arduino::Library::Model.database = database
        database.search(**opts)
      end
    end
  end
end
