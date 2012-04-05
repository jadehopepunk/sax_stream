module SaxStream
  module Mapper
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def node(name)
      end

      def map(attribute_name, options)
      end
    end
  end
end