require 'sax_stream/errors'
require 'sax_stream/internal/mapper_handler'
# require 'sax_stream/internal/sax_handler'
require 'sax_stream/internal/libxml_sax_handler'

module SaxStream
  class Parser
    def initialize(collector, mappers)
      raise ArgumentError, "You must supply your parser with a collector" unless collector
      raise ArgumentError, "You must supply your parser with at least one mapper class" if mappers.empty?
      # @sax_handler = Internal::SaxHandler.new(collector, mappers)
      @sax_handler = Internal::LibxmlSaxHandler.new(collector, mappers)
    end

    def parse_stream(io_stream, encoding = 'UTF-8')
      parser = LibXML::XML::SaxParser.io(io_stream)
      parser.callbacks = @sax_handler
      parser.parse

      # parser = Nokogiri::XML::SAX::Parser.new(@sax_handler)
      # parser.parse_io(io_stream, encoding)
    end
  end
end