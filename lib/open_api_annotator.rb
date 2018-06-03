require "active_support"
require "active_support/concern"
require "active_support/core_ext/class/subclasses"

require 'rails'

require 'open_api'

require 'open_api_annotator/field'
require 'open_api_annotator/attribute'
require 'open_api_annotator/association'
require 'open_api_annotator/version'
require 'open_api_annotator/errors'
require 'open_api_annotator/controller_annotatable'
require 'open_api_annotator/serializer_annotatable'
require 'open_api_annotator/type_validator'
require 'open_api_annotator/format_validator'
require 'open_api_annotator/nullable_validator'
require 'open_api_annotator/paths_builder'
require 'open_api_annotator/components_builder'
require 'open_api_annotator/spec_builder'

module OpenApiAnnotator
  def self.create_spec_yaml
    info = config.info
    spec = SpecBuilder.new.build(info: info)
    yaml = OpenApi::Serializers::YamlSerializer.new.serialize(spec)
    File.write(config.destination_path, yaml)
  end

  def self.configure(&block)
    block.call(config)
    config.validate!
  end

  def self.config
    @config ||= Config.new
  end

  class Config < Struct.new(
    :info,
    :destination_path,
    :path_regexp,
    :application_controller_class_name,
    :application_serializer_class_name,
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

    class InvalidError < StandardError; end
  end

  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/api_spec.rake"
    end
  end
end
