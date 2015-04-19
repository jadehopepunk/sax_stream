require 'sax_stream/internal/mappings/base'

module SaxStream
  module Internal
    module Mappings
      class Element < Base
        def map_value_onto_object(object, key, value)
          if value && @parser
            value = @parser.parse(value)
          end
          write_value_to_object object, value
        end

        def string_value_from_object(object)
          result = raw_value_from_object(object)
          result = @parser.format(result) if @parser && @parser.respond_to?(:format)
          result.to_s
        end

        def find_or_insert_node(doc, base)
          find_or_insert_nested_node(doc, base, path_parts)
        end

        private
          def raw_value_from_object(object)
            if object.respond_to?(@name) && !Object.new.respond_to?(@name)
              object.send(@name)
            else
              object[@name]
            end
          end

          def setter_method(name = nil)
            name ||= @name
            "#{name}=".to_sym
          end

          def write_value_to_object(object, value, name = nil)
            if object.respond_to?(setter_method(name))
              object.send(setter_method(name), value)
            else
              object[name || @name] = value
            end
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