module OpenApiAnnotator
  class Attribute < Field
    attr_accessor :format

    def initialize(name, type, format, nullable)
      super(name, type, nullable)
      self.format = format
    end
  end
end
