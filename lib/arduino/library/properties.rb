require_relative 'types'

module Arduino
  module Library

    class Properties < Dry::Struct
      constructor_type :symbolized

      Types::LIBRARY_PROPERTIES.each_pair do |field, type|
        self.attribute field, eval(type)
      end

      class << self
        attr_accessor :schema
      end

      hash = Types::LIBRARY_PROPERTIES.dup
      hash.each { |attribute, type| hash[attribute] = eval(type) }
      self.schema = Types::Hash.symbolized(hash)
    end
  end
end
