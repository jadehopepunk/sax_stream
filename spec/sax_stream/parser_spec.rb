require 'spec_helper'
require 'sax_stream/parser'

describe SaxStream::Parser do
  let(:collector) { double("collector") }

  it "raises an error if no mappers are supplied" do
    lambda {
      SaxStream::Parser.new(collector, [])
    }.should raise_error(ArgumentError)
  end
end