require 'nokogiri'
require 'sax_stream/internal/handler_stack'
require 'sax_stream/internal/combined_handler'

module SaxStream
  module Internal
    class SaxHandler < Nokogiri::XML::SAX::Document
      def initialize(collector, mappers, handler_stack = HandlerStack.new)
        @handler_stack = handler_stack
        mapper_handlers = mappers.map do |mapper|
          MapperHandler.new(mapper, collector, @handler_stack)
        end
        @handler_stack.root = CombinedHandler.new(@handler_stack, mapper_handlers)
      end

      [:start_element, :end_element, :characters, :cdata_block].each do |key|
        code = <<-RUBY
        def #{key}(*params)
          @handler_stack.top.#{key}(*params)
        end
        RUBY
        module_eval(code)
      end

      def error(string)
        raise ParsingError.new(string)
      end
    end
  end
end