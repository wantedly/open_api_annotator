module OpenApiAnnotator
  class PathsBuilder
    def build
      paths = OpenApi::Paths.new
      routes = RoutesFinder.new.find_all
      path_regexp = OpenApiAnnotator.config.path_regexp
      if path_regexp
        routes.select! { |route| route.path.match(path_regexp) }
      end
      routes.group_by(&:path).each do |path_name, routes|
        paths[path_name] = build_path_item(routes)
        puts "Path '#{path_name}' has been created."
      end

      paths
    end

    private

    def build_path_item(routes)
      path_item = OpenApi::PathItem.new
      routes.each do |route|
        media_type = resolve_media_type(route.controller_name, route.action_name)
        description = build_description(route.controller_name, route.action_name)
        next unless media_type
        response = OpenApi::Response.new(
          description: description,
          content: {
            "application/json" => media_type,
          }
        )
        operation = OpenApi::Operation.new(responses: OpenApi::Responses.new)
        operation.responses["200"] = response
        path_item.operations[route.http_verb.underscore] = operation
      end
      path_item
    end

    def build_description(controller_name, action_name)
      type = resolve_type(controller_name, action_name)
      return unless type

      case type
      when Array
        "Returns an array of #{type.first.name}"
      when Class
        "Returns a #{type.name}"
      else
        raise "not supported class #{type.class}"
      end
    end

    def resolve_media_type(controller_name, action_name)
      type = resolve_type(controller_name, action_name)
      return unless type

      case type
      when Array
        content_class = type.first
        reference = OpenApi::Reference.new(ref: "#/components/schemas/#{content_class.name}")
        schema = OpenApi::Schema.new(type: "array", items: reference)
        OpenApi::MediaType.new(schema: schema)
      when Class
        reference = OpenApi::Reference.new(ref: "#/components/schemas/#{type.name}")
        OpenApi::MediaType.new(schema: reference)
      else
        raise "not supported class #{type.class}"
      end
    end

    def resolve_type(controller_name, action_name)
      controller_class_name = "#{controller_name}_controller".classify
      begin
        controller_class = controller_class_name.constantize
      rescue NameError => e
        return
      end
      return unless controller_class < OpenApiAnnotator.config.application_controller_class

      controller_class.type_hash[action_name.to_sym]
    end
  end

  Route = Struct.new(:http_verb, :path, :controller_name, :action_name) do
    def initialize(http_verb:, path:, controller_name:, action_name:)
      self.http_verb = http_verb
      self.path = path
      self.controller_name = controller_name
      self.action_name = action_name
    end
  end

  class RoutesFinder
    def find_all
      @routes ||= Rails.application.routes.routes.routes.map do |route|
        path = PathResolver.new.resolve(route.path.ast)
        controller = route.requirements[:controller]
        action = route.requirements[:action]
        Route.new(http_verb: route.verb, path: path, controller_name: controller, action_name: action)
      end
    end
  end

  class PathResolver
    def resolve(ast)
      res = ""
      if ast.type == :CAT
        left = ast.left
        res +=
          if left.type == :SYMBOL
            "{#{left.name}}"
          else
            left.to_s
          end
        res += resolve(ast.right)
      end
      res
    end
  end
end
