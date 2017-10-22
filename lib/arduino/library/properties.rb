require_relative 'types'

module Arduino
  module Library
    # This class represents a single entry into the library-index.json file,
    # in other words — a `library.properties` file.
    class Properties < Dry::Struct
      # noinspection RubyResolve
      constructor_type :symbolized

      Types::LIBRARY_PROPERTIES.each_pair do |field, type|
        self.attribute field, eval(type)
      end

      class << self
        attr_writer :database

        def from_hash(hash)
          new(Types.schema[hash])
        end

        def from_json(json)
          from_hash(JSON.load(json))
        end

        def from_json_file(file)
          raise "File #{file} does not exist?" unless File.exist?(file)
          from_json(File.read(file))
        end

        def database(file = nil)
          return @database unless file
          raise "File #{file} does not exist?" unless File.exist?(file)
          hash = JSON.load(File.read(file))
          @database = []
          @database = hash['libraries'].map{|lib| from_hash(lib) }
        end
      end
    end
  end
end
