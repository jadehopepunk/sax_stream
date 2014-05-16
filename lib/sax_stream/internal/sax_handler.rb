require 'nokogiri'
require 'sax_stream/internal/handler_stack'
require 'sax_stream/internal/combined_handler'

module SaxStream
  module Internal
    class SaxHandler < Nokogiri::XML::SAX::Document
      ERROR_TYPES = {
        'Document is empty' => nil,
        'Start tag expected, \'<\' not found' => nil
      }

      def initialize(collector, mappers, handler_stack = HandlerStack.new)
        @handler_stack = handler_stack
        mapper_handlers = mappers.map do |mapper|
          MapperHandler.new(mapper, collector, @handler_stack)
        end
        @handler_stack.root = CombinedHandler.new(@handler_stack, mapper_handlers)
      end

      def start_element(*params)
        @handler_stack.top.start_element(*params)
      end

      def end_element(*params)
        @handler_stack.top.end_element(*params)
      end

      def characters(*params)
        @handler_stack.top.characters(*params)
      end

      def cdata_block(*params)
        @handler_stack.top.cdata_block(*params)
      end

      def error(message)
        klass = error_class(message)
        if klass
          raise klass.new(message.inspect)
        end
      end

      def error_class(message)
        message.strip!
        if ERROR_TYPES.has_key?(message)
          ERROR_TYPES[message]
        else
          ParsingError
        end
      end
    end
  end
end