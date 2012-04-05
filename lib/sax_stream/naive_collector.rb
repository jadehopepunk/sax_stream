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
  end
end