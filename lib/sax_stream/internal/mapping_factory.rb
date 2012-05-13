require 'sax_stream/internal/element_content_mapping'
require 'sax_stream/internal/element_attribute_mapping'
require 'sax_stream/internal/child_mapping'

module SaxStream
  module Internal
    class MappingFactory
      def self.build_mapping(name, options)
        last_part = options[:to].split('/').last
        klass = (last_part =~ /^@/ ? ElementAttributeMapping : ElementContentMapping)
        klass.new(name, options)
      end

      def self.build_relation(name, options)
        ChildMapping.new(name, options)
      end
    end
  end
end