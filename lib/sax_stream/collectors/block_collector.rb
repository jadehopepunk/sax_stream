module SaxStream
  module Collectors
    # Initialise this collector with a block that handles one argument. This collector will yield each
    # mapped object it collects immediately to the block. It will not keep a record of the objects.
    class BlockCollector
      def initialize(&block)
        @block = block
      end

      def <<(value)
        @block.call(value)
      end
    end
  end
end