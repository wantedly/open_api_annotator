module OpenApiAnnotator
  class Config < Struct.new(
    :info,
    :destination_path,
    :path_regexp,
    :application_controller_class_name,
    :application_serializer_class_name,
    :always_required_fields,
  )
    def application_serializer_class
      if application_serializer_class_name
        application_serializer_class_name.constantize
      else
        unless defined?(ApplicationSerializer)
          raise <<~EOL
            Expected to define ApplicationSerializer or set custom class like:

            ```
            OpenApiAnnotator.configure do |config|
              config.application_serializer_class = BaseSerializer
            end
            ```
          EOL
        end
        ApplicationSerializer
      end
    end

    def application_controller_class
      if application_controller_class_name
        application_controller_class_name.constantize
      else
        unless defined?(ApplicationController)
          raise <<~EOL
            Expected to define ApplicationController or set custom class like:

            ```
            OpenApiAnnotator.configure do |config|
              config.application_controller_class = BaseSerializer
            end
            ```
          EOL
        end
        ApplicationController
      end
    end

    def validate!
      validate_info!
      validate_destination_path!
      validate_path_regexp!
      validate_application_controller_class_name!
      validate_application_serializer_class_name!
      validate_always_required_fields!
    end

    def validate_info!
      unless info
        raise InvalidError, <<~EOL
          You have to set `OpenApi::Info` to `config.info` like:

          ```
          OpenApiAnnotator.configure do |config|
            config.info = OpenApi::Info.new(title: "Book API", version: "1")
          end
          ```

          You can see the detail of `OpenApi::Info` in
          https://www.rubydoc.info/gems/open_api/OpenApi/Info
        EOL
      end
    end

    def validate_destination_path!
      unless destination_path
        raise InvalidError, <<~EOL
          You have to set `config.destination_path` like:

          ```
          OpenApiAnnotator.configure do |config|
            config.destination_path = Rails.root.join("api_spec.yml")
          end
          ```
        EOL
      end
    end

    def validate_path_regexp!
      # Do nothing
    end

    def validate_application_serializer_class_name!
      # Do nothing
    end

    def validate_application_controller_class_name!
      # Do nothing
    end

    def validate_always_required_fields!
      # Do nothing
    end

    class InvalidError < StandardError; end
  end
end
