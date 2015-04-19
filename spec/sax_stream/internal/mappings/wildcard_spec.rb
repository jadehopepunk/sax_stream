require 'sax_stream/internal/mappings/wildcard'

module SaxStream::Internal::Mappings
  describe Wildcard do
    context "#map_value_onto_object" do
      subject {Wildcard.new recursive: true}

      before do
        @result = {}
      end

      it "maps attribute" do
        subject.map_value_onto_object(@result, "@attr", '1')
        @result.should == {
            'attr' => '1'
        }
      end

      it "maps attribute" do
        subject.map_value_onto_object(@result, "child/@attr", '1')
        @result.should == {
          'child' => {
            'attr' => '1'
          }
        }
      end
    end
  end
end