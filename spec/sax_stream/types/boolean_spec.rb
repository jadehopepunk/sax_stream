require 'spec_helper'
require 'sax_stream/types/boolean'

describe SaxStream::Types::Boolean do
  describe "parsing" do
    it "is nil if string is nil" do
      SaxStream::Types::Boolean.parse(nil).should == nil
    end

    it "is nil if string is empty" do
      SaxStream::Types::Boolean.parse('').should == nil
    end

    it "is nil if string is just spaces" do
      SaxStream::Types::Boolean.parse(" \t\n").should == nil
    end

    it "is true for 1" do
      SaxStream::Types::Boolean.parse("1 ").should == true
    end

    it "if false for 0" do
      SaxStream::Types::Boolean.parse("0").should == false
    end

    it "is true for YES" do
      SaxStream::Types::Boolean.parse("YES").should == true
    end

    it "if false for NO" do
      SaxStream::Types::Boolean.parse("NO").should == false
    end

    it "is true for TRUE" do
      SaxStream::Types::Boolean.parse("1 ").should == true
    end

    it "if false for FALSE" do
      SaxStream::Types::Boolean.parse("0").should == false
    end
  end
end
