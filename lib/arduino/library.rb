require 'open-uri'

module Arduino
  module Library
    unless defined?(DEFAULT_ARDUINO_LIBRARY_INDEX_URL)
      DEFAULT_ARDUINO_LIBRARY_INDEX_URL  =
        'http://downloads.arduino.cc/libraries/library_index.json.gz'
      DEFAULT_ARDUINO_LIBRARY_PATH       =
        ENV['ARDUINO_CUSTOM_LIBRARY_PATH'] || (ENV['HOME'] + '/Documents/Arduino/Libraries')
      DEFAULT_ARDUINO_LIBRARY_INDEX_PATH =
        ENV['ARDUINO_LIBRARY_INDEX_PATH'] ||
          (ENV['HOME'] + '/Documents/Arduino/Libraries/index.json.gz')
    end
  end
end

require 'arduino/library/version'
require 'arduino/library/utilities'
require 'arduino/library/types'
# noinspection RubyResolve
require 'arduino/library/model'
require 'arduino/library/database'
require 'arduino/library/default_database'
require 'arduino/library/finder'
require 'arduino/library/instance_methods'

module Arduino
  module Library
    class << self
      def included(base)
        base.include(::Arduino::Library::InstanceMethods)
        base.include(::Arduino::Library::Finder::FinderMethods)
      end

      included(Arduino::Library)
    end

  end
end

Arduino::Library.extend(Arduino::Library)

