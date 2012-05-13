module SaxStream
  module Internal
    module Mappings
      class Element
        def initialize(name, options = {})
          @name = name.to_s
          @path = options[:to]
          process_conversion_type(options[:as])
        end

        def map_value_onto_object(object, value)
          if value && @parser
            value = @parser.parse(value)
          end
          if object.respond_to?(setter_method)
            object.send(setter_method, value)
          else
            object[@name] = value
          end
        end

        def value_from_object(object)
          object[@name]
        end

        def handler_for(name, collector, handler_stack, parent_object)
        end

        def path_parts
          @path.split('/')
        end

        def find_or_insert_node(doc, base)
          find_or_insert_nested_node(doc, base, path_parts)
        end

        private
          def find_or_insert_nested_node(doc, base, remaining_parts)
            part = remaining_parts.shift
            if part
              find_or_insert_path_part(doc, base, part, remaining_parts)
            else
              base
            end
          end

          def find_or_insert_path_part(doc, base, part, remaining_parts)
            node = find_or_insert_child_element(doc, base, part)
            find_or_insert_nested_node(doc, node, remaining_parts)
          end

          def find_or_insert_child_element(doc, base, part)
            base.search(part).first || insert_child_element(doc, base, part)
          end

          def insert_child_element(doc, base, part)
            doc.create_element(part).tap do |element|
              base << element
            end
          end

          def setter_method
            "#{@name}=".to_sym
          end

          def process_conversion_type(as)
            if as
              if as.respond_to?(:parse)
                @parser = as
              else
                raise ArgumentError, ":as options for #{@name} field is a #{as.inspect} which must respond to parse"
              end
            end
          end
      end
    end
  end
end