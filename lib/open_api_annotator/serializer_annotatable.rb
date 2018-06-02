module OpenApiAnnotator
  module SerializerAnnotatable
    extend ActiveSupport::Concern

    module ClassMethods
      def skip_open_api_validation!
        @open_api_validation_skipped = true
      end

      def attribute(attr, options = {}, &block)
        validate_open_api_options(attr, options)
        super(attr, options, &block)
      end

      def has_many(name, options = {}, &block)
        validate_open_api_options(name, options)
        super(name, options, &block)
      end

      def has_one(name, options = {}, &block)
        validate_open_api_options(name, options)
        super(name, options, &block)
      end

      def belongs_to(name, options = {}, &block)
        validate_open_api_options(name, options)
        super(name, options, &block)
      end

      def validate_open_api_options(field, options)
        return if @open_api_validation_skipped

        validate_open_api_type!(options[:type])
        validate_open_api_format!(options[:format])
        validate_open_api_nullable!(options[:nullable])
      rescue ValidationError => e
        Rails.logger.warn(e.message)
      end

      def validate_open_api_type!(type)
        @open_api_type_validator ||= TypeValidator.new
        @open_api_type_validator.validate!(type)
      end

      def validate_open_api_nullable!(type)
        @open_api_nullable_validator ||= NullableValidator.new
        @open_api_nullable_validator.validate!(type)
      end

      def validate_open_api_format!(format)
        @open_api_format_validator ||= FormatValidator.new
        @open_api_format_validator.validate!(format)
      end

      def open_api_has_many_associations
        _reflections.values.select { |reflection|
          reflection.is_a?(ActiveModel::Serializer::HasManyReflection)
        }.map do |reflection|
          serializer_class = reflection.options[:serializer]
          type = serializer_class ? [serializer_class.open_api_resource_name] : reflection.options[:type]
          Association.new(reflection.name.to_sym, type, reflection.options[:nullable])
        end
      end

      def open_api_has_one_associations
        _reflections.values.select { |reflection|
          reflection.is_a?(ActiveModel::Serializer::HasOneReflection)
        }.map do |reflection|
          serializer_class = reflection.options[:serializer]
          type = serializer_class ? [serializer_class.open_api_resource_name] : reflection.options[:type]
          Association.new(reflection.name.to_sym, type, reflection.options[:nullable])
        end
      end

      def open_api_belongs_to_associations
        _reflections.values.select { |reflection|
          reflection.is_a?(ActiveModel::Serializer::BelongsToReflection)
        }.map do |reflection|
          serializer_class = reflection.options[:serializer]
          type = serializer_class ? [serializer_class.open_api_resource_name] : reflection.options[:type]
          Association.new(reflection.name.to_sym, type, reflection.options[:nullable])
        end
      end

      def open_api_attributes
        _attributes_data.values.reject { |attribute|
          attribute.name.to_s.start_with?("_")
        }.map { |attribute|
          serializer_class = attribute.options[:serializer]
          type = serializer_class ? [serializer_class.open_api_resource_name] : attribute.options[:type]
          Attribute.new(attribute.name.to_sym, type, attribute.options[:format], attribute.options[:nullable])
        }
      end

      def open_api_resource_name
        name.remove(/Serializer\z/)
      end
    end
  end
end
