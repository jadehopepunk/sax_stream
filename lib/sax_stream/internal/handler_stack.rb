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

      def pop
        raise ProgramError, "can't pop the last handler" if @handlers.length <= 1
        @handlers.pop
      end
    end
  end
end