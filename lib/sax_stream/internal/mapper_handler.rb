module SaxStream
  module Internal
    class MapperHandler
      def initialize(mapper_class, collector)
        @mapper_class = mapper_class
        @collector = collector
      end
    end
  end
end