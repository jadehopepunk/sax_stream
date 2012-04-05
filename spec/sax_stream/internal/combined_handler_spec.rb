require 'spec_helper'
require 'sax_stream/internal/combined_handler'

describe SaxStream::Internal::CombinedHandler do
  it "raises error when characters received"
  it "raises error when element ends"
  context "when element starts" do
    it "finds the first matching mapper handler, pushes it onto the stack, and forwards the message"
    it "raises an error if no mapper handler matches"
  end
end