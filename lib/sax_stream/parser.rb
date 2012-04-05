require 'sax_stream/errors'
require 'sax_stream/internal/mapper_handler'
require 'sax_stream/internal/sax_handler'

module SaxStream
  class Parser
    def initialize(collector, mappers)
      raise ArgumentError, "You must supply your parser with a collector" unless collector
      raise ArgumentError, "You must supply your parser with at least one mapper class" if mappers.empty?

      mapper_handlers = mappers.map do |mapper|
        Internal::MapperHandler.new(mapper, collector)
      end
      @sax_handler = Internal::SaxHandler.new(mapper_handlers)
    end

    def parse_stream(io_stream)
      parser = Nokogiri::XML::SAX::Parser.new(@sax_handler)
      parser.parse(io_stream)
    end
  end
end