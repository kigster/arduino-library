require 'spec_helper'

RSpec.describe Arduino::Library do

  PUBLIC_METHODS = Arduino::Library.methods - Object.methods

  class Foo
    require 'arduino/library/include'
  end

  let(:foo) { Foo.new }

  PUBLIC_METHODS.each do |method|
    it "##{method}" do
      expect(foo.respond_to?(method)).to be true
    end
  end
end
