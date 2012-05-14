require 'sax_stream/internal/mappings/base'

module SaxStream
  module Internal
    module Mappings
      class Element < Base
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
          if object.respond_to?(@name) && !Object.new.respond_to?(@name)
            object.send(@name)
          else
            object[@name]
          end
        end

        def find_or_insert_node(doc, base)
          find_or_insert_nested_node(doc, base, path_parts)
        end

        private
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