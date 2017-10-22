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
    end
  end
end
