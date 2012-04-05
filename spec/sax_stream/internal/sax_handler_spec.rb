require 'spec_helper'
require 'sax_stream/internal/sax_handler'

module SaxStream
  describe Internal::SaxHandler do
    let(:mapping_handler)  { double("mapping handler", :stack= => nil) }
    let(:mapping_handlers) { [mapping_handler] }
    let(:top)              { double("top handler") }
    let(:stack)            { double("HandlerStack", :top => top, :root= => nil) }
    let(:subject)          { Internal::SaxHandler.new(mapping_handlers, stack) }

    it "forwards start_element to the top of the stack" do
      top.should_receive(:start_element).with('article', [['key', 'value']])
      subject.start_element('article', [['key', 'value']])
    end

    it "forwards end_element to the top of the stack" do
      top.should_receive(:end_element).with('article', [['key', 'value']])
      subject.end_element('article', [['key', 'value']])
    end

    it "assigns the stack to the handers passed in" do
      mapping_handler.should_receive(:stack=).with(stack)
      Internal::SaxHandler.new(mapping_handlers, stack)
    end
  end
end