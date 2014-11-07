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

    it "handles negative numbers" do
      SaxStream::Types::Decimal.parse("-12.0").should == -12.0
    end

    it "is nil if the string is not a valid float" do
      SaxStream::Types::Decimal.parse("fish").should be_nil
      SaxStream::Types::Decimal.parse("-12.0-0.1").should be_nil
    end
  end
end
