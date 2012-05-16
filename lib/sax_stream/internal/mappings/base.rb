module SaxStream
  module Internal
    module Mappings
      class Base
        attr_reader :name

        def initialize(name, options = {})
          @name = name.to_s
          @path = options[:to]
          process_conversion_type(options[:as])
        end

        def handler_for(name, collector, handler_stack, parent_object)
        end

        def path_parts
          @path.split('/').reject {|part| part.nil? || part == ''}
        rescue => e
          raise "could not split #{@path.inspect} for #{@name.inspect}"
        end

        def map_value_onto_object(object, value)
        end

        def find_or_insert_parent_node(doc, base)
          find_or_insert_nested_node(doc, base, path_parts.tap(&:pop))
        end

        def update_parent_node(builder, doc, parent, object)
          raise NotImplementedError
        end

        private

          def find_or_insert_nested_node(doc, base, remaining_parts)
            part = remaining_parts.shift
            return base unless part
            node = find_or_insert_child_element(doc, base, part)
            find_or_insert_nested_node(doc, node, remaining_parts)
          end

          def find_or_insert_child_element(doc, base, part)
            return base if part.nil?
            base.search(part).first || insert_child_element(doc, base, part)
          rescue Nokogiri::XML::XPath::SyntaxError => e
            raise "Nokogiri syntax error when searching for path part #{part.inspect} as part of #{@path.inspect} for #{@name.inspect} mapping "
          end

          def insert_child_element(doc, base, part)
            doc.create_element(part).tap do |element|
              base << element
            end
          end


      end
    end
  end
end