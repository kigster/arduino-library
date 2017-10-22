require 'open-uri'
require 'zlib'
require 'json'

require 'arduino/library'
require 'arduino/library/model'

module Arduino
  module Library

    # This class represents a single entry into the library-index.json file,
    # in other words — a `library.properties` file.
    class Database

      class << self
        alias from new

        def default
          new
        end
      end

      attr_accessor :local_file, :temp_file, :db_list

      def initialize(file_or_url = Arduino::Library::DEFAULT_ARDUINO_LIBRARY_INDEX_URL)
        raise ArgumentError, 'Empty file_or_url provided' unless file_or_url

        self.temp_file = open(file_or_url)
        if file_or_url.end_with?('.gz')
          self.local_file = Zlib::GzipReader.new(temp_file)
        else
          self.local_file = temp_file
        end

        load_json
      end

      # Usage: find(attr1: value, attr2: /regexp/, ... )
      def find(**opts)
        limit = opts[:limit]
        opts.delete(:limit)
        match_list = []

        db_list.find do |entry|
          matches = true

          opts.each_pair do |attr, check|
            value   = entry.send(attr)
            matches = case check
                        when String
                          value == check
                        when Regexp
                          check.matches?(value)
                        when Array
                          value.include?(check)
                        else
                          raise InvalidArgument, "Class #{check.class.name} is unsupported for value checks"
                      end
            break unless matches
          end

          match_list << entry if matches

          break if limit && match_list.size >= limit
        end
        if block_given?
          match_list.each { |entry| yield(entry) }
        end
        match_list
      end

      private

      def load_json
        hash         = JSON.load(local_file.read)
        self.db_list = hash['libraries'].map { |lib| Model.from_hash(lib) }
      end

      alias to_a db_list
    end
  end
end
