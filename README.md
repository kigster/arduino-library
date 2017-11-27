[![Gem Version](https://badge.fury.io/rb/arduino-library.svg)](https://badge.fury.io/rb/arduino-library)
[![Build Status](https://travis-ci.org/kigster/arduino-library.svg?branch=master)](https://travis-ci.org/kigster/arduino-library)
[![Maintainability](https://api.codeclimate.com/v1/badges/0da01eba1b556826a231/maintainability)](https://codeclimate.com/github/kigster/arduino-library/maintainability)
[![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/arduino-library?type=total)](https://rubygems.org/gems/arduino-library)

[![Test Coverage](https://api.codeclimate.com/v1/badges/0da01eba1b556826a231/test_coverage)](https://codeclimate.com/github/kigster/arduino-library/test_coverage)
[![Test Coverage](https://codeclimate.com/github/kigster/arduino-library/badges/coverage.svg)](https://codeclimate.com/github/kigster/arduino-library/coverage)

# Arduino::Library

> NOTE: This gem is the underpinning for [Arli](https://github.com/kigster/arli) — command line Arduino Library manager.

This library offers a ruby model representing an Arduino Library, including field validation, reading and writing the [`library.properties`](https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5:-Library-specification#library-metadata) file, or searching for libraries in the official database.

Searching for a library will transparently download and cache the Arduino-maintained JSON database of official libraries locally, so that future searches are fast. 

The library also provides validation functionality for the `library.properties` file for your custom libraries you would like to open source.
 
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

Please take a look at the following screencast:

[![asciicast](https://asciinema.org/a/145645.png)](https://asciinema.org/a/145645)

### Configuration

The gem database can be configured to download the default database from a custom URL, 
and to cache it in a local file. Next time the lookup is invoked local file is checked first. Library automatically checks the size of the remote index file, and re-downloads it if the file has changed.

You can modify the source of the default database and the local cache location using one of two methods:

 1. By settin the environment variables before invoking the gem;
 2. Or by configuring the `DefaultDatabase` class variables.

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
Arduino::Library::DefaultDatabase.reload!
```

#### Default Values:

Please review the [`library.rb`](https://github.com/kigster/arduino-library/blob/master/lib/arduino/library.rb) file to understand how these variables are resolved.

### Finding and Resolving Arduino Libraries

The primary module `Arduino::Library` provides a convenient Facáde into all of the library functionality. Therefore you can use the library by calling these methods directly, such as `Arduino::Library.library_from(..)` or by including the module in your current context.

Below we'll include the top level module, and use the shortcut methods to explore available functionality. That said, if you prefer not to include the top level module, you can call the same functions directly on the module itself.

There are two ways to include the DSL in your context:

```ruby
require 'arduino/library'
class Foo
  include Arduino::Library::InstanceMethods
end
```

Or, perhaps even easier:

```ruby
class Foo
  require 'arduino/library/include'
end
```

### Facáde Methods

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

In the next section you will read about the search, but the truth is that the `library_from` method actualy will fall back to search if you provide a partial hash. The allowed values in the hash are: `name, checksum, archiveFileName`. Since these keys often uniquely identify a library, the gem attempts to find it for you.

```ruby
require 'arduino/library/include' #=> true
library_from(name: 'AudioZero')
    => #<Arduino::Library::Model 
            name="AudioZero" 
            version="1.1.1" 
            author="Arduino" 
            maintainer="Arduino <info@arduino.cc>"
            ..........>

library_from(checksum: 'SHA-256:4604a3b92b9f4a7dd92534eb09247443fa5078e6bd0e7a2c5f3060eaba2ad974')
    => #<Arduino::Library::Model 
            name="AudioZero" 
            version="1.1.1" 
            author="Arduino" 
            maintainer="Arduino <info@arduino.cc>"
            ..........>
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

### Low-level API

The Facade is the recommended way to use library. Below we briefly describe the low-level API of the underlying classes.

#### `Arduino::Library::Database`

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
database.search(author: 'Paul Stoffregen').size #=> 21
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

#### `Arduino::Library::Model` 

> Use this class to operate on a single library.

##### Reading Library from an External Source using `.from`

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

#### Presenters

Presenters are there to convert to and from a particular format.

##### `.properties` Presenter

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
