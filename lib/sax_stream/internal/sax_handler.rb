require 'nokogiri'

module SaxStream
  module Internal
    class SaxHandler < Nokogiri::XML::SAX::Document
      def initialize(mapper_handlers)
        @mapper_handlers = mapper_handlers
      end
    end
  end
end