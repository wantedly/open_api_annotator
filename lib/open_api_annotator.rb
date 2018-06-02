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
  end

  def self.config
    @config ||= Config.new
  end

  class Config < Struct.new(
    :info,
    :destination_path,
    :path_regexp,
    :application_controller_class,
    :application_serializer_class,
  )
    def application_serializer_class
      if super
        super
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
      if super
        super
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
  end
end
