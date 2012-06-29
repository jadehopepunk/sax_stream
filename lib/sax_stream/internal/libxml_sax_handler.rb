require 'libxml'
require 'sax_stream/internal/handler_stack'
require 'sax_stream/internal/combined_handler'

module SaxStream
  module Internal
    class LibxmlSaxHandler
      include LibXML::XML::SaxParser::Callbacks

      def initialize(collector, mappers, handler_stack = HandlerStack.new)
        @handler_stack = handler_stack
        mapper_handlers = mappers.map do |mapper|
          MapperHandler.new(mapper, collector, @handler_stack)
        end
        @handler_stack.root = CombinedHandler.new(@handler_stack, mapper_handlers)
      end

      def method_missing(*params)
        puts "received #{params.inspect}"
      end

      def on_start_element(*params)
        @handler_stack.top.start_element(*params)
      end

      def on_end_element(*params)
        @handler_stack.top.end_element(*params)
      end

      def on_characters(*params)
        @handler_stack.top.characters(*params)
      end

      def on_cdata_block(*params)
        @handler_stack.top.cdata_block(*params)
      end

      def error(string)
        raise ParsingError.new(string)
      end
    end
  end
end