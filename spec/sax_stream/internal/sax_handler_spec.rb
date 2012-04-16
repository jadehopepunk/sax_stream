require 'spec_helper'
require 'sax_stream/internal/sax_handler'

module SaxStream
  module Internal
    describe SaxHandler do
      unless defined?(MapperHandler)
        class MapperHandler
          def initialize(mapper_class, collector, handler_stack)
          end
        end
      end

      let(:mapping_class)    { double("mapping class") }
      let(:mapping_classes)  { [mapping_class] }
      let(:mapping_handler)  { double("mapping handler", :stack= => nil) }
      let(:mapping_handlers) { [mapping_handler] }
      let(:top)              { double("top handler") }
      let(:collector)        { double("collector") }
      let(:stack)            { double("HandlerStack", :top => top, :root= => nil) }
      let(:subject)          { SaxHandler.new(collector, mapping_classes, stack) }

      it "forwards start_element to the top of the stack" do
        top.should_receive(:start_element).with('article', [['key', 'value']])
        subject.start_element('article', [['key', 'value']])
      end

      it "forwards end_element to the top of the stack" do
        top.should_receive(:end_element).with('article', [['key', 'value']])
        subject.end_element('article', [['key', 'value']])
      end

      it "raises an exception if an error is found" do
        lambda {
          subject.error("error text")
        }.should raise_error(ParsingError)
      end
    end
  end
end