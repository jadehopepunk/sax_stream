require 'sax_stream/errors'

module SaxStream
  module Internal
    class CombinedHandler
      def initialize(stack, mapper_handlers)
        @stack = stack
        @handlers = mapper_handlers
      end

      def start_element(name, *other_params)
        handler = handle_for_element_name(name)
        raise UnexpectedNode, "Could not find a handler for the element start: #{name.inspect}" unless handler
        @stack.push(handler)
        handler.start_element(name, *other_params)
      end

      private

        def handle_for_element_name(name)
          @handlers.detect do |handler|
            handler if handler.maps_node?(name)
          end
        end
    end
  end
end