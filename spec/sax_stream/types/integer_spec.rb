require 'spec_helper'
require 'sax_stream/types/integer'

describe SaxStream::Types::Integer do
  describe "parsing" do
    it "is nil if string is nil" do
      SaxStream::Types::Integer.parse(nil).should == nil
    end

    it "is nil if string is empty" do
      SaxStream::Types::Integer.parse('').should == nil
    end

    it "is nil if string is just spaces" do
      SaxStream::Types::Integer.parse(" \t\n").should == nil
    end

    it "parses integer out of string" do
      SaxStream::Types::Integer.parse("123").should == 123
    end

    it "handles commas" do
      SaxStream::Types::Integer.parse("1,234").should == 1234
    end

    it "doesn't include decimal points" do
      SaxStream::Types::Integer.parse("1,234.67").should == 1234
    end
  end
end
