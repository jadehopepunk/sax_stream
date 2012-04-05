require 'spec_helper'
require 'sax_stream/mapper'

describe SaxStream::Mapper do
  let(:object) { Hash.new }

  before do
    Object.class_eval do
      class Sample
        include SaxStream::Mapper
      end
    end
  end

  after do
    Object.send(:remove_const, :Sample)
  end

  context "node" do
    it "sets the class node name" do
      Sample.node 'foobar'
      Sample.node_name.should == 'foobar'
    end
  end

  context "mapping attributes" do
    it "will set value of that path on object if attribute exists" do
      Sample.map :some_key, :to => 'foo/bar'
      Sample.map_key_onto_object(object, 'foo/bar', 'testval')
      object['some_key'].should == 'testval'
    end

    it "wont set value of that path on object if attribute doesnt exist" do
      Sample.map :some_key, :to => 'foo/bar'
      Sample.map_key_onto_object(object, 'foo/bar/rar', 'testval')
      object.should be_empty
    end
  end
end
