module SaxStream
  module Internal
    class HandlerStack
      def initialize(root_handler)
        raise ArgumentError unless root_handler
        @handlers = [root_handler]
      end

      def top
        @handlers.last
      end

      def push(handler)
        @handlers.push(handler)
      end

      def pop
        raise ProgramError, "can't push the last handler" if @handlers.length <= 1
        @handlers.pop
      end
    end
  end
end