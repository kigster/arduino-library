require 'open-uri'
require 'fileutils'
require 'zlib'

module Arduino
  module Library
    module Utilities

      def read_file_or_url(file_or_url)
        raise ArgumentError, 'Empty file_or_url provided' unless file_or_url
        temp_file = open(file_or_url)
        open_plain_or_gzipped(file_or_url, temp_file)
      end

      def open_plain_or_gzipped(file_or_url, temp_file = nil)
        if file_or_url =~ /\.gz$/i
          Zlib::GzipReader.new(temp_file || File.open(file_or_url))
        else
          temp_file
        end
      end

      def backup_previous_library(path)
        debug "backup previous library: #{path.bold.green}"
        new_name = nil
        index    = 0

        loop do
          index += 1

          new_name = "#{path}.#{index}"
          break unless File.exist?(new_name)
          debug "file #{new_name.bold.green} exists, next..."
          raise 'Too many backup versions created, delete some first' if index > 20
        end

        debug "moving #{path.bold.green}", "to #{new_name.bold.blue}"
        FileUtils.move(path, new_name)
      end

      def download(url, path)
        open(path, 'wb') do |file|
          file << open(url).read
        end
      end

      def debug(*msgs)
        puts "\n" + msgs.join("\n") if ENV['DEBUG']
      end
    end
  end
end
