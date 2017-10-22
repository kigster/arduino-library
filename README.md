[![Build Status](https://travis-ci.org/kigster/arduino-library.svg?branch=master)](https://travis-ci.org/kigster/arduino-library)

# Arduino::Library

This gem encapsulates various rules about the [`library.properties`](https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5:-Library-specification#library-metadata) file that contains meta-data about Arduino Libraries.

It also provides convenient shortcuts for downloading the Arduino-maintained database of published libraries in JSON format, searching for various libraries, choosing a version, and more.

It also provides validation functionality for the `library.properties` file for your custom libraries you would like to open source.
 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arduino-library'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arduino-library

## Usage

Current version only contains Ruby-based API and is meant to be consumed by other projects (in particularly, check out [Arli](https://github.com/kigster/arli) — a command-line tool and an Arduino Library Manager and installer). This project is invaluable if you are you using, for example, [arduino-cmake](https://github.com/arduino-cmake/arduino-cmake) project to build and upload your Arduino Code.

### Load List of Libraries from a JSON Index

```ruby
# You can load libraries from a local JSON file, or from a remote URL, eg:  
database = Arduino::Library.from('http://downloads.arduino.cc/libraries/library_index.json.gz')

# or, since the above link is the default location of Arduino-maintained libraries,
database = Arduino::Library.default # is equivalent to the above

# or, load it from a local JSON file, that can be optionally gzipped: 
database = Arduino::Library.from('library_index.json.gz')

# Once the library is initialized, the following operations are supported:
database.find(name: 'AudioZero', version: '1.0.1') do |audio_zero|
  audio_zero.website        #=> http://arduino.cc/en/Reference/Audio
  audio_zero.architectures  #=> [ 'samd' ] 
  audio_zero.download!(to: '/tmp', validations: [ :checksum, :schema ] )
  # => true (will be downloaded to /tmp/AudioZero)
end

# Once the library is initialized, the following operations are supported:
database.find(name: 'AudioZero') do |audio_zero_versions|
  audio_zero_versions.last.version # => '1.0.1'
  audio_zero_versions.size         # => 12
  audio_zero_versions.last.class   # => Arduino::Library::Properties
end

database.categories # => [ "Display",
                      #      "Communication",
                      #      "Signal Input/Output",
                      #      "Sensors",
                      #      "Device Control",
                      #      "Timing",
                      #      "Data Storage",
                      #      "Data Processing",
                      #      "Other"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kigster/arduino-library](https://github.com/kigster/arduino-library).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
