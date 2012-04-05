require 'spec_helper'
require 'sax_stream/parser'

describe SaxStream::Parser do
  it "raises an error if no mappers are supplied" do
    lambda {
      SaxStream::Parser.new({})
    }.should raise_error(ArgumentError)
  end
end