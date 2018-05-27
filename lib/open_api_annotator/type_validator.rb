module OpenApiAnnotator
  class TypeValidator
    def validate!(type)
      if type.is_a?(Array)
        validate_as_collection_resource!(type)
      else
        validate_as_single_resource!(type)
      end
    end

    private

    def validate_as_collection_resource!(type)
      unless type.size == 1
        raise ValidationError, "type array should have one element, but it has #{type.size}."
      end

      validate_as_single_resource!(type[0])
    end

    def validate_as_single_resource!(type)
      case type
      when Symbol
        unless type.in?(OpenApi::DataTypes.all_types)
          raise ValidationError, "type should be a symbol of: #{OpenApi::DataTypes.all_types.join(", ")}, but got #{type}."
        end
      when Class
        # pass
      when NilClass
        raise ValidationError, "type should not be nil."
      else
        raise ValidationError, "type is unexpected class #{type.class}."
      end
    end
  end
end
