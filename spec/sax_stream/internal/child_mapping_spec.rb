require 'spec_helper'
require 'sax_stream/internal/child_mapping'

module SaxStream
  module Internal
    describe ChildMapping do
      let(:mapper1)       { double("mapper1", :maps_node? => nil, :map_key_onto_object => nil) }
      let(:collector)     { double("collector") }
      let(:handler_stack) { double("handler stack") }
      let(:handler)       { double("handler") }

      context "fetching handler" do
        it "is nil if has no mapper which maps nodes of this name" do
          mapping = ChildMapping.new('catalogue', :as => mapper1)

          mapping.handler_for('banana', collector, handler_stack).should be_nil
        end

        it "builds a new handler if it has a mapper which maps nodes of this name" do
          mapper1.stub!(:maps_node?).with('product').and_return(true)
          mapping = ChildMapping.new('catalogue', :as => mapper1)
          MapperHandler.should_receive(:new).with(mapper1, collector, handler_stack).and_return(handler)

          mapping.handler_for('product', collector, handler_stack).should == handler
        end
      end
    end
  end
end