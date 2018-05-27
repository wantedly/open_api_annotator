module OpenApiAnnotator
  class ComponentsBuilder
    def build
      components = OpenApi::Components.new(schemas: {})

      serializers = fetch_all_serializers
      serializers.sort_by!(&:open_api_resource_name)
      serializers.each do |serializer|
        schema = build_schema(serializer)
        next unless schema
        components.schemas[serializer.open_api_resource_name] = schema
        puts "Schema component '#{serializer.open_api_resource_name}' has been created."
      end
      components
    end

    private

    def build_schema(serializer)
      schema = OpenApi::Schema.new(type: "object", properties: {})

      # attributes
      serializer.open_api_attributes.map do |attribute|
        next unless attribute.valid?
        schema.properties[attribute.name.to_sym] = OpenApi::Schema.new(
          type: attribute.type,
          format: attribute.format,
          nullable: attribute.nullable,
        )
      end

      # has-many associations
      serializer.open_api_has_many_associations.each do |association|
        next unless association.valid?
        content = association.type.first
        return unless content
        content_name = content.try(:name) || content.to_s
        schema.properties[association.name.to_sym] = OpenApi::Schema.new(
          type: "array",
          items: OpenApi::Reference.new(ref: "#/components/schemas/#{content_name}"),
          nullable: association.nullable,
        )
      end

      # has-one and blongs-to associations
      associations = serializer.open_api_has_one_associations + serializer.open_api_belongs_to_associations
      associations.each do |association|
        next unless association.valid?
        content_name = association.type.try(:name) || association.type.to_s
        schema.properties[association.name.to_sym] = OpenApi::Reference.new(ref: "#/components/schemas/#{content_name}")
      end

      schema
    end

    def fetch_all_serializers
      require_all_serializers!

      ApplicationSerializer.descendants
    end

    def require_all_serializers!
      all_serializer_features = Dir["#{Rails.root}/app/serializers/**/*_serializer.rb"]
      unloaded_features = all_serializer_features - $LOADED_FEATURES
      unloaded_features.each { |f| require f }
    end
  end
end
