require 'spec_helper'
require 'sax_stream/mapper'

describe SaxStream::Mapper do
  let(:object)        { Hash.new }
  let(:collector)     { double("collector") }
  let(:handler_stack) { double("handler stack") }

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

  context "mapping children" do
    before do
      Object.class_eval do
        class Post
          include SaxStream::Mapper
          node 'post'
        end
        class Article
          include SaxStream::Mapper
          node 'article'
        end
      end
    end

    after do
      Object.send(:remove_const, :Post)
      Object.send(:remove_const, :Article)
    end

    it "will return a child handler for a mapped child" do
      Sample.children :listings, :as => [Post, Article]
      result = Sample.child_handler_for('article', collector, handler_stack)

      result.should_not be_nil
      result.mapper_class.should == Article
      result.collector.should == collector
    end

    it "wont return a child handler for an unmapped child" do
      Sample.children :listings, :as => [Post, Article]
      Sample.child_handler_for('feature', collector, handler_stack).should be_nil
    end
  end
end
