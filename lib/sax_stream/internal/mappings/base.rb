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
          @path.split('/')
        end

        def map_value_onto_object(object, value)
        end


      end
    end
  end
end