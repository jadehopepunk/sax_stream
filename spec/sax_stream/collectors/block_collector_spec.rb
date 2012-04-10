require 'spec_helper'
require 'sax_stream/collectors/block_collector'

module SaxStream
  module Collectors
    describe BlockCollector do
      let(:object) { double("mapped object") }

      context "when receiving object" do
        it "yields object to the block" do
          results = []
          collector = BlockCollector.new do |value|
            results << value
          end
          collector << object
          results.should == [object]
        end
      end
    end
  end
end