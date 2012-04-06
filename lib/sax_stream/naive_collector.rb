module SaxStream
  class NaiveCollector
    def initialize
      @objects = []
    end

    def mapped_objects
      @objects
    end

    def <<(value)
      @objects << value
    end

    def for_type(klass)
      mapped_objects.select { |object| object.class == klass }
    end
  end
end