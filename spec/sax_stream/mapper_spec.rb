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

    it "will allow mapping to a key which is empty string, to denote root content" do
      Sample.map :some_key, :to => ''
      Sample.map_key_onto_object(object, '', 'testval')
      object['some_key'].should == 'testval'
    end
  end

  context "mapping related children" do
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
      Sample.relate :listings, :to => '*', :as => [Post, Article]
      result = Sample.child_handler_for('article', {}, collector, handler_stack, anything)

      result.should_not be_nil
      result.mapper_class.should == Article
      result.collector.should == collector
    end

    it "wont return a child handler for an unmapped child" do
      Sample.relate :listings, :to => '*', :as => [Post, Article]
      Sample.child_handler_for('feature', {}, collector, handler_stack, anything).should be_nil
    end

    it "defines an accessor for the related objects" do
      Sample.relate :listings, :to => '*', :as => [Post, Article]
      relation = Sample.new.relations['listings']
      relation.should_not be_nil
      relation.should be_empty
      relation.should respond_to(:<<)
    end
  end

  context "building xml" do
    let(:sample)  { Sample.new }
    let(:builder) { double("xml builder") }

    it "should ask the XML builder to build XML for itself" do
      builder.should_receive(:build_xml_for).with(sample).and_return('foobar')
      sample.to_xml(nil, builder).should == 'foobar'
    end
  end
end
