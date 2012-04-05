require 'nokogiri'
require 'sax_stream/internal/handler_stack'
require 'sax_stream/internal/combined_handler'

module SaxStream
  module Internal
    class SaxHandler < Nokogiri::XML::SAX::Document
      def initialize(mapper_handlers, handler_stack = HandlerStack.new)
        handler_stack.root = CombinedHandler.new(handler_stack, mapper_handlers)
        @handler_stack = handler_stack
      end

      [:start_element, :end_element].each do |key|
        code = <<-RUBY
        def #{key}(*params)
          @handler_stack.top.#{key}(*params)
        end
        RUBY
        module_eval(code)
      end
    end
  end
end