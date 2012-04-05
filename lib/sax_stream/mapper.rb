module SaxStream
  module Mapper
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def node(name)
        @node_name = name
      end

      def map(attribute_name, options)
      end

      def node_name
        @node_name
      end
    end
  end
end