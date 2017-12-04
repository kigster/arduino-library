require 'json'
require 'forwardable'
require 'arduino/library/model'
require 'arduino/library/utilities'
require 'colored2'

module Arduino
  module Library
    # This class represents a single entry into the library-index.json file,
    # in other words — a `library.properties` file.
    class Database

      include Utilities
      extend Forwardable

      class << self
        alias from new
      end

      def_delegators :@db_list,
                     *(Array.new.methods -
                       Object.methods - [:search])

      attr_accessor :local_file,
                    :db_list

      def initialize(file_or_url)
        self.local_file = read_file_or_url(file_or_url)
        load_json
      end

      # Usage: search(attr1: value, attr2: /regexp/, ... )
      def search(**opts)
        limit = opts[:limit]
        opts.delete(:limit)
        match_list = []

        db_list.select do |entry|
          matches = entry_matches?(entry, opts)
          match_list << entry if matches
          break if limit && match_list.size >= limit
        end

        match_list.each { |entry| yield(entry) } if block_given?
        match_list
      end

      protected

      def entry_matches?(entry, opts)
        matches = true
        opts.each_pair do |attr, check|
          value   = entry.send(attr)
          matches &= case check
                       when String
                         value == check
                       when Regexp
                         value =~ check
                       when Array
                         value = value.split(',') unless value.is_a?(Array)
                         value.eql?(check) || value.include?(check) || value.first == '*'
                       when Proc
                         check.call(value)
                       else
                         raise ::OptionParser::InvalidArgument, "Class #{check.class.name} is unsupported for value checks"
                     end
          break unless matches
        end
      end

      private

      def load_json
        hash         = JSON.load(local_file.read)
        self.db_list = hash['libraries'].map { |lib| Model.from_hash(lib) }
      end
    end
  end
end
