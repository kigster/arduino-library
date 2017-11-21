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
        new_name = path + ".#{short_time}"
        debug "moving #{path.bold.green}", "to #{new_name.bold.blue}"
        FileUtils.move(path, new_name)
      end

      def download(url, path)
        debug "dowloading from [#{url.to_s.bold.red}]"
        debug "             to [#{path.to_s.bold.green}]"
        open(path, 'wb') do |file|
          file << open(url).read
        end
      end

      def debug(*msgs)
        puts "\n" + msgs.join("\n") if ENV['DEBUG']
      end

      def short_time(time = Time.now)
        time.strftime('%Y%m%d-%H%M%S')
      end
    end
  end
end
