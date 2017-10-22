require 'arduino/library/types'
require 'arduino/library/model'

module Arduino
  module Library
    module Presenters
      class Properties < Struct.new(:model)
        attr_accessor :presented

        def initialize(*args)
          super(*args)
          self.presented = ''
        end

        # Primary instance method, returns a string representing a
        # library.properties format file, using the model.
        # The presented value is cached in the #presented public instance
        # variable.
        def present
          Types::LIBRARY_PROPERTIES.keys.each do |attr|
            value = model.send(attr) if model && model.respond_to?(attr)
            next unless value
            if value.is_a?(Array)
              self.presented << "#{attr}=#{model.send(attr).join(',')}\n"
            else
              self.presented << "#{attr}=#{model.send(attr)}\n"
            end
          end
          presented
        end

        class << self
          # Class method, that reads a properties file and returns a properly
          # validated Arduino::Library::Model instance.
          def from_file(file)
            props = File.read(file).split(/\n/)
            hash  = {}
            props.each do |line|
              attr, value = line.split('=')
              attr        = attr.to_sym
              if Types::ARRAY_ATTRIBUTES.include?(attr)
                hash[attr] = value.split(',')
              else
                hash[attr] = value
              end
            end

            ::Arduino::Library::Model.from_hash(hash)
          end
        end
      end
    end
  end
end

