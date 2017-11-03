[![Gem Version](https://badge.fury.io/rb/arduino-library.svg)](https://badge.fury.io/rb/arduino-library)
[![Build Status](https://travis-ci.org/kigster/arduino-library.svg?branch=master)](https://travis-ci.org/kigster/arduino-library)
[![Maintainability](https://api.codeclimate.com/v1/badges/0da01eba1b556826a231/maintainability)](https://codeclimate.com/github/kigster/arduino-library/maintainability)
[![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/arduino-library?type=total)](https://rubygems.org/gems/arduino-library)

[![Test Coverage](https://api.codeclimate.com/v1/badges/0da01eba1b556826a231/test_coverage)](https://codeclimate.com/github/kigster/arduino-library/test_coverage)
[![Test Coverage](https://codeclimate.com/github/kigster/arduino-library/badges/coverage.svg)](https://codeclimate.com/github/kigster/arduino-library/coverage)

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


### Configuration

The gem database can be configured to download the default database from a custom URL, 
keep a local cache in a custom file. It always downloads the index locally, and next time
it's invoked, the local file is used (if and only if it's size is identical 
to the remote file).

You can change the configuration in two ways:

 1. Set environment variables before invoking the gem
 2. Configure the `DefaultDatabase` class variables

#### Setting Environment Variables

 * `ARDUINO_CUSTOM_LIBRARY_PATH` can be used to change local top-level path to the libraries folder.
 * `ARDUINO_LIBRARY_INDEX_PATH` can be used to change the location of the cached index file.

#### Change Class Variables for `DefaultDatabase` Class

The following class variables can be changed, like so:

```ruby
Arduino::Library::DefaultDatabase.library_index_url = ''
```

 * `library_index_url` — URL to download compressed JSON index.
 * `library_index_path` — local path to the cached compressed JSON index.
 * `library_path` — local top-level folder where your Arduino libraries are.

If you change any of the above, please reload the database with:

```ruby
Arduino::Library::DefaultDatabase.instance.setup
```

#### Default Values:

```ruby
DEFAULT_ARDUINO_LIBRARY_INDEX_URL  =
   'http://downloads.arduino.cc/libraries/library_index.json.gz'
   
DEFAULT_ARDUINO_LIBRARY_PATH       =
    ENV['ARDUINO_CUSTOM_LIBRARY_PATH'] || (ENV['HOME'] + '/Documents/Arduino/Libraries')

DEFAULT_ARDUINO_LIBRARY_INDEX_PATH =
    ENV['ARDUINO_LIBRARY_INDEX_PATH'] ||
    (ENV['HOME'] + '/Documents/Arduino/Libraries/index.json.gz')
```

### Using the top-level module

If you prefer not to have hard-coded dependencies on the `Arduino::Library::*` sub-classes and sub-modules, you can use the top level module, which proxies several shortcut methods.

You can access these methods in two different ways:

  1. By including the top-level module in your context, and using methods as instance methods in the current context, eg. `#db_default`
  2. As class methods on `Arduino::Library`, for example `Arduino::Library.db_default`

Below we'll focus on the first usage, but if you prefer to use the first syntax, it's there and available for you.

You can require the library for use in the DSL:

```ruby
class Foo
  # this loads the library, and includes its methods in the current context
  require 'arduino/library/include
  
  # alternatively
  include Arduino::Library::InstanceMethods
end
```

#### Using `db_from`

This method returns an instance of the `Arduino::Library::Database` from the provided source:

```ruby
db_from('library_index.json').size 
# => 16
db_from('library_index.json.gz').size
# => 16
db_from('http://downloads.arduino.cc/libraries/library_index.json.gz').size 
# => 3653
# This required downloading a 400K gzipped file into a temp file, and reading from there.
```

#### Using `db_default`

This method downloads and returns the official Arduino-maintained index of Arduino libraries.

```ruby
db_default.size
# => 3653
```

#### Using `library_from`

This method reads from a source that can be of many formats (see below) and returns an instantiated `Arduino::Library::Model` for this library. You can then get all library attributes via corresponding methods:

```ruby
library_from('spec/fixtures/audio_zero.json').name 
# => 'AudioZero'
library_from('~/Documents/Arduino/Libraries/AudioZero/library.properties').name 
#=> 'AudioZero'
library_from('https://raw.githubusercontent.com/PaulStoffregen/DS1307RTC/master/library.properties').name
#=> 'DS1307RTC'
```

#### Using `search`

Method `search` is, perhaps, some of the most powerful functionality in this gem. It allows constructing very flexible and precise queries, to match any number of library attributes.

The method has the following signature:

```ruby
search(database = db_default, **opts)
```

`opts` is a Hash that you can use to pass attributes with matchers. All matching results are returned as an array of models.

**Examples**

Here is searching for 'AudioZero' and sorting results by the version number:

```ruby
search(name: 'AudioZero').sort.first.version #=> "1.0.0"
search(name: 'AudioZero').sort.last.version  #=> "1.1.1"
```

You can search by any attribute, not just name and number:

```ruby
results = search(
  # direct string equality
  name:           'AudioZero',
  
  # regexp matching is fully supported 
  author:         /konstantin/i,              
  
 # array is matched if it's a subset or equality, or if library has '*'
  architectures:  [ 'avr' ],
  
  # or a proc for max flexibility
  version:        proc do |value|
    value.start_with?('1.')
  end
)

results.size 
#=> <whatever number of matches returned>
```

Note that multiple attributes must ALL match for the library to be included in the result set.

### `Arduino::Library::Database`

> Downloading the index of all libraries, and searching for a library.

You can load libraries from a local JSON file, or from a remote URL, eg:  

```ruby 
require 'arduino/library'

database = Arduino::Library::Database.from(
  'http://downloads.arduino.cc/libraries/library_index.json.gz')
```

or, since the above link happens to be the default location of Arduino-maintained librarie index file, you can use the `default` method instead:

```ruby
database = Arduino::Library::DefaultDatabase.instance
```

or, load the list from a local JSON file, that can be optionally gzipped (just like the URL):

```ruby
database = Arduino::Library::Database.from('library_index.json.gz')
```

Once the library is initialized, the following operations are supported:

```ruby
database.search(name: 'AudioZero', version: '1.0.1') do |audio_zero|
  audio_zero.website        #=> http://arduino.cc/en/Reference/Audio
  audio_zero.architectures  #=> [ 'samd' ] 
end
```

You can pass any of the attributes to #search, and the value can be a `String` (in which case only equality matches), or a regular expression, eg:

```ruby
database.search(author: "Paul Stoffregen").size #=> 21
database.search(author: /stoffregen/i).size     #=> 33
```

You interate over multiple using either a block:

```ruby
database.search(name: 'AudioZero') do |match|
  puts match.name # => 'AudioZero'
  puts match.version # => will print all versions of the library available
end
```

or, just grab the return value from `#search`, which is always an array.

```ruby
all_versions = database.search(name: 'AudioZero')
# => [ Arduino::Library::Model<name: AudioZero, version: '1.0.1',... >, .. ]
```

### `Arduino::Library::Model` 

> Use this class to operate on a single library.

#### Reading Library from an External Source using `.from`

You can use an intelligent class method `.from` that attempts to auto-detect the type of file or URL you are passing as an argument, and use an appropriate parser for each type. 

For example, to read from a JSON file: 

```ruby
json_file = 'spec/fixtures/audio_zero.json'
model = Arduino::Library::Model.from(json_file)
model.name #=> 'AudioZero'
```

Or to read from the `.properties` file:

```ruby
properties_file = 'spec/fixtures/audio_zero.properties'
model = Arduino::Library::Model.from(properties_file)
model.name #=> 'AudioZero'
```

### Presenters

Presenters are there to convert to and from a particular format.

#### `.properties` Presenter

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kigster/arduino-library](https://github.com/kigster/arduino-library).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
