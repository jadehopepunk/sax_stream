require 'spec_helper'
require 'sax_stream/internal/element_stack'

module SaxStream
  describe Internal::ElementStack do
    let(:subject) { Internal::ElementStack.new }

    it "starts empty" do
      subject.top_name.should be_nil
    end

    it "can push a new element onto the top" do
      subject.push('fat', [])
      subject.top_name.should == 'fat'
    end

    it "can pop a handler and it is no longer top" do
      subject.push('fat', [])
      subject.pop
      subject.top_name.should be_nil
    end

    context "attributes" do
      it "raises error if no element" do
        lambda {
          subject.attributes
        }.should raise_error(ProgramError)
      end

      it "returns attributes on first element" do
        subject.push('fat', [['a', 'b'], ['c', 'd']])
        subject.attributes.should == [
          ['fat/@a', 'b'],
          ['fat/@c', 'd']
        ]
      end

      it "returns attributes with full relative path" do
        subject.push('fat', [['e', 'f']])
        subject.push('brown', [])
        subject.push('fox', [['a', 'b'], ['c', 'd']])
        subject.attributes.should == [
          ['fat/brown/fox/@a', 'b'],
          ['fat/brown/fox/@c', 'd']
        ]
      end
    end
  end
end