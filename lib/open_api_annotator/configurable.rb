module OpenApiAnnotator
  module Configurable
    extend ActiveSupport::Concern

    class_methods do
      def configure(&block)
        block.call(config)
        config.validate!
      end

      def config
        @config ||= Config.new(nil, nil, nil, nil, nil, false)
      end
    end
  end
end
