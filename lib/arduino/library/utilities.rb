require 'open-uri'

module Arduino
  module Library

    module Utilities
      def read_file_or_url(file_or_url)
        raise ArgumentError, 'Empty file_or_url provided' unless file_or_url
        temp_file = open(file_or_url)
        if file_or_url =~ /\.gz$/i
          Zlib::GzipReader.new(temp_file)
        else
          temp_file
        end
      end
    end

  end
end
