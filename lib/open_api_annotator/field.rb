module OpenApiAnnotator
  class Field < Struct.new(:name, :type, :nullable)
    def valid?
      return false if name.nil?
      return false if type.nil?
      return false if nullable.nil?

      true
    end
  end
end
