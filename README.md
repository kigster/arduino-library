[![Build Status](https://travis-ci.org/kigster/arduino-library.svg?branch=master)](https://travis-ci.org/kigster/arduino-library)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0da01eba1b556826a231/test_coverage)](https://codeclimate.com/github/kigster/arduino-library/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/0da01eba1b556826a231/maintainability)](https://codeclimate.com/github/kigster/arduino-library/maintainability)

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

### Downloading Library Index, parsing and searching for a library

You can load libraries from a local JSON file, or from a remote URL, eg:  

```ruby 
require 'arduino/library'

database = Arduino::Library::Database.from(
  'http://downloads.arduino.cc/libraries/library_index.json.gz')
```

or, since the above link happens to be the default location of Arduino-maintained librarie index file, you can use the `default` method instead:

```ruby
database = Arduino::Library::Database.default
```

or, load the list from a local JSON file, that can be optionally gzipped (just like the URL):

```ruby
database = Arduino::Library::Database.from('library_index.json.gz')
```


Once the library is initialized, the following operations are supported:

```ruby
database.find(name: 'AudioZero', version: '1.0.1') do |audio_zero|
  audio_zero.website        #=> http://arduino.cc/en/Reference/Audio
  audio_zero.architectures  #=> [ 'samd' ] 
end
```

You can pass any of the attributes to #find, and the value can be a `String` (in which case only equality matches), or a regular expression, eg:

```ruby
database.find(author: "Paul Stoffregen").size #=> 21
database.find(author: /stoffregen/i).size     #=> 33
```

You interate over multiple using either a block:

```ruby
database.find(name: 'AudioZero') do |match|
  puts match.name # => 'AudioZero'
  puts match.version # => will print all versions of the library available
end
```

or, just grab the return value from `#find`, which is always an array.

```ruby
all_versions = database.find(name: 'AudioZero')
# => [ Arduino::Library::Model<name: AudioZero, version: '1.0.1',... >, .. ]
```

### Use `Arduino::Library::Model` to operate on a single library definition

You can use class methods `.from_json_file` or `.from_hash` to instantiate library models:

```ruby
require 'arduino/library'

json_file = 'spec/fixtures/audio_zero.json'

model = Arduino::Library::Model.from_json_file(json_file)
model.name #=> 'AudioZero'
```

### Using presenters to convert between alternative representations

#### Properties Presenter

```ruby
props = Arduino::Library::Presenters::Properties.new(model).present
File.open('/tmp/audio_zero.properties', 'w') do |f|
   f.write(props)
end

# this creates a file in the format:

# name=AudioZero
# version=1.0.1
# etc.
```

You can use the same presenter to load from this file format instead:

```ruby
lib = Arduino::Library::Presenters::Properties.from_file(
  '~/Documents/Arduino/Libraries/AudioZero/library.properties'
)

lib.name    #=> 'AudioZero'
lib.version #=> '1.0.1'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kigster/arduino-library](https://github.com/kigster/arduino-library).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
