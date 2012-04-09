require 'spec_helper'
require 'sax_stream/types/decimal'

describe SaxStream::Types::Decimal do
  describe "parsing" do
    it "is nil if string is nil" do
      SaxStream::Types::Decimal.parse(nil).should == nil
    end

    it "is nil if string is empty" do
      SaxStream::Types::Decimal.parse('').should == nil
    end

    it "is nil if string is just spaces" do
      SaxStream::Types::Decimal.parse(" \t\n").should == nil
    end

    it "parses integer out of string" do
      SaxStream::Types::Decimal.parse("123").should == 123
    end

    it "handles commas" do
      SaxStream::Types::Decimal.parse("1,234").should == 1234
    end

    it "includes decimal points" do
      SaxStream::Types::Decimal.parse("1,234.67").should == 1234.67
    end
  end
end
