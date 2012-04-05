require 'sax_stream/errors'
require 'sax_stream/internal/mapper_handler'
require 'sax_stream/internal/sax_handler'

module SaxStream
  class Parser
    def initialize(collector_mappers)
      raise ArgumentError, "You must supply your parser with at least one collector and mapper class" if collector_mappers.empty?
      mapper_handlers = []
      collector_mappers.each do |collector, mappers|
        mappers_array = mappers.is_a?(Enumerable) ? mappers : [mappers]
        mappers_array.each do |mapper|
          mapper_handlers << Internal::MapperHandler.new(mapper, collector)
        end
      end
      @sax_handler = Internal::SaxHandler.new(mapper_handlers)
    end

    def parse_stream(io_stream)
      parser = Nokogiri::XML::SAX::Parser.new(@sax_handler)
      parser.parse(io_stream)
    end
  end
end