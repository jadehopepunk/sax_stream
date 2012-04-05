require 'spec_helper'
require 'sax_stream/internal/combined_handler'

module SaxStream
  describe Internal::CombinedHandler do
    let(:stack)    { double("HandlerStack") }
    let(:handler1) { double("handler 1", :maps_node? => false) }
    let(:handler2) { double("handler 2", :maps_node? => false) }
    let(:subject)  { Internal::CombinedHandler.new(stack, [handler1, handler2]) }

    context "when element starts" do
      it "finds the first matching mapper handler, pushes it onto the stack, and forwards the message" do
        stack.should_receive(:push).with(handler2)
        handler2.stub!(:maps_node?).with('article').and_return(true)
        handler2.should_receive(:start_element).with('article', [['key', 'value']])

        subject.start_element('article', [['key', 'value']])
      end

      it "raises an error if no mapper handler matches" do
        lambda {
          subject.start_element('article', [['key', 'value']])
        }.should raise_error(UnexpectedNode)
      end
    end
  end
end