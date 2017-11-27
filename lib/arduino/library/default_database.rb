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
                      :library_index_url,
                      :url_size_cache

        def instance
          @default ||= self.send(:new)
        end

        def reload!
          instance.reload!
        end

        def assign_defaults
          self.url_size_cache     ||= {}
          self.library_index_path ||= DEFAULT_ARDUINO_LIBRARY_INDEX_PATH
          self.library_index_url  ||= DEFAULT_ARDUINO_LIBRARY_INDEX_URL
          self.library_path       ||= DEFAULT_ARDUINO_LIBRARY_PATH
        end
      end

      self.assign_defaults

      attr_accessor :url, :path

      def initialize
        reload!
      end

      def reload!
        self.url  = self.class.library_index_url
        self.path = self.class.library_index_path

        FileUtils.mkpath(File.dirname(path))

        download_if_needed!

        self.local_file = open_plain_or_gzipped(path)

        load_json
      end

      def download_if_needed!
        if File.exist?(path)
          remote_size = get_remote_size(url)
          local_size  = File.size(path)
          debug("remote size: #{remote_size}, local size: #{local_size}")
          return if remote_size == local_size
          backup_previous_library(path)
        end
        download(url, path)
      end

      def get_remote_size(url)
        with_caching(url) do
          resp = HTTParty.head(url)
          resp['content-length'].to_i
        end
      end

      def with_caching(url, &_block)
        @cache ||= self.class.url_size_cache
        @cache[url] ||= yield
      end
    end
  end
end
