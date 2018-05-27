module OpenApiAnnotator
  class NullableValidator
    def validate!(nullable)
      if nullable.nil?
        raise ValidationError, "nullable should not be nil."
      end
    end
  end
end
