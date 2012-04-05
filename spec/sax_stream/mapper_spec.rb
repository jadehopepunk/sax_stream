require 'spec_helper'
require 'sax_stream/mapper'

describe SaxStream::Mapper do
  context "node" do
    it "sets the class node name" do
      class Sample
        include SaxStream::Mapper
        node 'foobar'
      end

      Sample.node_name.should == 'foobar'
    end
  end

  context "mapping attributes" do

  end
end
