require 'dry-types'
require 'dry-struct'
require 'uri'

module Arduino
  module Library
    module Types
      include Dry::Types.module

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
        website:         'Types::Url',
        category:        'Types::Category',
        architectures:   'Types::Json::Array.member(Types::Architecture)',
        types:           'Types::Json::Array.member(Types::LibraryTypes)',
        url:             'Types::Url',
        archiveFileName: 'Types::FileName',
        size:            'Types::Coercible::Int',
        checksum:        'Types::Checksum',
        dot_a_linkage:   'Types::Bool.optional',
        includes:        'Types::Json::Array.member(Types::FileName).optional',
      }.freeze

      ARRAY_ATTRIBUTES = LIBRARY_PROPERTIES.keys.select { |k| LIBRARY_PROPERTIES[k] =~ /Array/ }

      class << self
        attr_accessor :schema
      end

      # Let's keep the original hash intact; otherwise dry-struct munges it.
      hash = LIBRARY_PROPERTIES.dup
      hash.each { |attribute, type| hash[attribute] = eval(type) }

      self.schema = Types::Hash.symbolized(hash)
    end
  end
end
