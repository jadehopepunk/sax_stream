module SaxStream
  module Internal
    class SingularRelationshipCollector
      def initialize(parent, relation_name)
        @parent = parent
        @relation_name = relation_name
      end

      def <<(value)
        if @parent.relations[@relation_name]
          raise ProgramError, "found singular relationship #{@relation_name.inspect} occuring more than once. Existing is #{@parent.relations[@relation_name].inspect}"
        end
        @parent.relations[@relation_name] = value
      end
    end
  end
end