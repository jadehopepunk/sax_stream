module SaxStream
  module Internal
    class HandlerStack
      def initialize(root_handler)
        @root = root_handler
      end

      def top
        @root
      end
    end
  end
end