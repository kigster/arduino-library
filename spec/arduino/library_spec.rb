require 'spec_helper'

RSpec.describe Arduino::Library do
  it 'has a version number' do
    expect(Arduino::Library::VERSION).not_to be nil
  end

  context '#from_json_file' do
  #   @libraries = Arduino::Library.from_json_file('library_index.json')
  #   @libraries.find(name: 'AudioZero', version: '1.0.1') do |audio_zero|
  #     audio_zero.website        #=> http://arduino.cc/en/Reference/Audio
  #     audio_zero.architectures  #=> [ 'samd' ]
  #     audio_zero.download!(to: '/tmp', validations: [ :checksum, :schema ] )
  #     # => true (will be downloaded to /tmp/AudioZero)
  #   end
  #
  #   @libraries.categories # => [ "Display",
  #                         #      "Communication",
  #                         #      "Signal Input/Output",
  #                         #      "Sensors",
  #                         #      "Device Control",
  #                         #      "Timing",
  #                         #      "Data Storage",
  #                         #      "Data Processing",
  #                         #      "Other"]
  #
  end
end
