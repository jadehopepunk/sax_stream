require 'spec_helper'
require 'sax_stream/internal/mapper_handler'

module SaxStream
  describe Internal::MapperHandler do
    let(:new_mapped_object) { double("instance of mapper class") }
    let(:mapper_class)      { double("mapper class", :new => new_mapped_object) }
    let(:collector)         { double("collector") }
    let(:subject)           { Internal::MapperHandler.new(mapper_class, collector) }

    context "maps_node" do
      it "is true if name equal node name" do
        mapper_class.stub!(:node_name).and_return('client')
        subject.maps_node?('client').should be_true
      end

      it "is false if name doesnt equal node name" do
        mapper_class.stub!(:node_name).and_return('employer')
        subject.maps_node?('client').should be_false
      end
    end

    context "start_element" do
      it "instantiates a mapped object" do
        subject.start_element('client')
        subject.current_object.should == new_mapped_object
      end

      it "sets attributes on the mapped object" do
        mapper_class.should_receive(:map_attribute_onto_object).with(new_mapped_object, 'a', 'b')
        subject.start_element('client', [['a', 'b']])
      end
    end
  end
end