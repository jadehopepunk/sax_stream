require 'spec_helper'
require 'sax_stream/core_extensions/ordered_hash'

module SaxStream
  module CoreExtensions
    describe OrderedHash do
      it "can be converted to a regular hash" do
        ordered = OrderedHash.new
        ordered['a'] = 1
        ordered['b'] = 2
        ordered.to_hash.should == {'a' => 1, 'b' => 2}
      end
    end
  end
end