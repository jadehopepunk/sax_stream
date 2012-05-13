require 'sax_stream/internal/mappings/element_content'
require 'sax_stream/internal/mappings/element_attribute'
require 'sax_stream/internal/mappings/child'

module SaxStream
  module Internal
    class MappingFactory
      def self.build_mapping(name, options)
        last_part = options[:to].split('/').last
        klass = (last_part =~ /^@/ ? Mappings::ElementAttribute : Mappings::ElementContent)
        klass.new(name, options)
      end

      def self.build_relation(name, options)
        Mappings::Child.new(name, options)
      end
    end
  end
end