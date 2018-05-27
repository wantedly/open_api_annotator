module OpenApiAnnotator
  class SpecBuilder
    def build(info:)
      paths = PathsBuilder.new.build
      components = ComponentsBuilder.new.build

      OpenApi::Specification.new(
        openapi: "3.0.1",
        info: info,
        paths: paths,
        components: components,
      )
    end
  end
end
