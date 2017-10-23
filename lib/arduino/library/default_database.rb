require 'httparty'
require 'open-uri'
require_relative 'database'

module Arduino
  module Library
    # This class represents a single entry into the library-index.json file,
    # in other words — a `library.properties` file.

    class DefaultDatabase < Database

      class << self
        attr_accessor :library_index_path,
                      :library_path,
                      :library_index_url

        def instance
          @default ||= self.send(:new)
        end
      end

      self.library_index_path ||= DEFAULT_ARDUINO_LIBRARY_INDEX_PATH
      self.library_index_url  ||= DEFAULT_ARDUINO_LIBRARY_INDEX_URL
      self.library_path       ||= DEFAULT_ARDUINO_LIBRARY_PATH

      attr_accessor :url, :path

      def initialize
        setup
      end

      def setup
        self.url  = self.class.library_index_url
        self.path = self.class.library_index_path

        download_if_needed!

        self.local_file = open_plain_or_gzipped(path)

        load_json
      end

      def download_if_needed!
        if File.exist?(path)
          resp        = HTTParty.head(url)
          remote_size = resp['content-length'].to_i
          local_size  = File.size(path)
          debug("remote: #{remote_size}, local #{local_size}")
          return if remote_size == local_size
          backup_previous_library(path)
        end

        download(url, path)
      end

    end
  end
end
