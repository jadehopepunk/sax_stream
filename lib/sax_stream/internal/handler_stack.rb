module SaxStream
  module Internal
    class HandlerStack
      def initialize()
        @handlers = []
      end

      def root=(value)
        @handlers = [value]
      end

      def top
        @handlers.last
      end

      def push(handler)
        @handlers.push(handler)
      end

      def pop(handler = nil)
        raise ProgramError, "can't pop the last handler" if @handlers.length <= 1
        raise ProgramError, "popping handler that isn't the top" if handler && handler != @handlers.last
        @handlers.pop
      end
    end
  end
end