require 'dry-types'
require 'dry-struct'
require 'uri'

module Arduino
  module Library
    module Types
      include ::Dry::Types.module

      Name    = String.constrained format: /^[A-Za-z_.-][A-Za-z0-9 _.-]*[A-Za-z0-9_.-]$/
      Version = String.constrained format: /[0-9]+\.[0-9]+(\.[0-9]+)?/

      Url = String.constrained format: URI::regexp(%w(http https))

      Category = String.enum('Display',
                             'Signal Input/Output',
                             'Communication',
                             'Sensors',
                             'Device Control',
                             'Timing',
                             'Data Storage',
                             'Data Processing',
                             'Uncategorized',
                             'Other')

      Architecture = String.enum(
          '*',
          'AVR',
          'ESP8266',
          'FP51',
          'OpenBCI 32',
          'RFduino',
          'SAM',
          'SAMD',
          'STM32F1',
          'Simblee',
          'Simula',
          'all',
          'ameba',
          'arc32',
          'arm',
          'atmelavr',
          'avr',
          'esp32',
          'esp8266',
          'nRF5',
          'nRF51822',
          'nRF52832',
          'nrf52',
          'pic32',
          'rtl8195a',
          'sam',
          'samd',
          'simblee',
          'stm32',
          'stm32f4',
          'teensy',
          'tiny')

      LibraryTypes = String.enum(
          'Arduino',
          'Contributed',
          'Partner',
          'Recommended',
          'Retired'
      )

      FileName = String.constrained(
          format: /[a-zA-Z0-9_=.:]+/
      )

      Checksum = String.constrained(
          format: /SHA-256:[0-9a-fA-F]{64}/
      )

      StringField = Coercible::String

      LIBRARY_PROPERTIES = {
          name:            'Types::String',
          version:         'Types::String',
          author:          'Types::String',
          maintainer:      'Types::String',
          sentence:        'Types::String',
          paragraph:       'Types::String',
          website:         'Types::String',
          category:        'Types::Category',
          architectures:   'Types::JSON::Array.of(Types::Architecture)',
          types:           'Types::JSON::Array.of(Types::LibraryTypes)',
          url:             'Types::Url',
          archiveFileName: 'Types::FileName',
          size:            'Types::Coercible::Integer',
          checksum:        'Types::Checksum',
          dot_a_linkage:   'Types::Bool.optional',
          includes:        'Types::JSON::Array.of(Types::FileName).optional',
      }.freeze

      SymbolizeAndOptionalSchema = Types::Hash.
        schema({}).
        with_key_transform(&:to_sym).
        with_type_transform { |type| type.meta(omittable: true) }

      ARRAY_ATTRIBUTES = LIBRARY_PROPERTIES.keys.select { |k| LIBRARY_PROPERTIES[k] =~ /Array/ }

      class << self
        attr_accessor :schema
      end

      module Properties
        class << self
          def extended(base)
            base.extend(Generator)
          end
        end

        module Generator
          def generate_attributes!(source = {}, eval_extra = '')
            constantize_property_hash(source, eval_extra).each_pair do |attr, type|
              attribute attr, type
            end
          end

          def constantize_property_hash(source = {}, eval_extra = '')
            {}.tap do |attr_hash|
              source.each_pair do |attribute, type|
                attr_hash[attribute] = eval("#{type}#{eval_extra}")
              end
            end
          end

          def schema_for(source = {})
            ::Arduino::Library::Types::SymbolizeAndOptionalSchema.schema(
                constantize_property_hash(source)
            )
          end
        end
      end

      extend Properties

      self.schema = schema_for LIBRARY_PROPERTIES
    end
  end
end
