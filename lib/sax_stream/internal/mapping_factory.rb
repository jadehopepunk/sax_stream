require 'sax_stream/internal/element_content_mapping'
require 'sax_stream/internal/child_mapping'

module SaxStream
  module Internal
    class MappingFactory
      def self.build_mapping(name, options)
        Internal::ElementContentMapping.new(name, options)
      end

      def self.build_relation(name, options)
        Internal::ChildMapping.new(name, options)
      end
    end
  end
end