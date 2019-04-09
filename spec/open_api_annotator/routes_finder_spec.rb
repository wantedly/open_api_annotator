require 'spec_helper'

RSpec.describe OpenApiAnnotator::RoutesFinder do
  describe "#find_all" do
    subject { described_class.new.find_all }

    let(:path) { double(:path) }
    let(:rails_application) { double(:rails_application) }
    let(:route_set) { double(:route_set) }
    let(:routes) { double(:routes) }
    let(:array_of_route) { [journey_route] }
    let(:journey_route) { double(:journey_route) }

    before do
      allow(path).to receive(:ast).and_return(double(:ast))
      allow(journey_route).to receive(:path).and_return(path)
      allow(journey_route).to receive(:verb).and_return("GET")
      allow(journey_route).to receive(:requirements).and_return({ controller: "/api/v1/books", action: "show" })
      allow(Rails).to receive(:application).and_return(rails_application)
      allow(rails_application).to receive(:routes).and_return(route_set)
      allow(route_set).to receive(:routes).and_return(routes)
      allow(routes).to receive(:routes).and_return(array_of_route)
      allow_any_instance_of(OpenApiAnnotator::PathResolver).to receive(:resolve).and_return("/api/v1/books/{id}")
    end

    it "returns all routes" do
      is_expected.to match(
        [
          OpenApiAnnotator::Route.new(
            http_verb: "GET",
            path: "/api/v1/books/{id}",
            controller_name: "/api/v1/books",
            action_name: "show"
          )
        ]
      )
    end
  end
end

RSpec.describe OpenApiAnnotator::PathResolver do
  describe "#resolve" do
    subject { described_class.new.resolve(ast, parameters_context) }

    let(:ast) do
      ActionDispatch::Journey::Nodes::Cat.new(
        ActionDispatch::Journey::Nodes::Slash.new("/"),
        ActionDispatch::Journey::Nodes::Cat.new(
          ActionDispatch::Journey::Nodes::Literal.new("api"),
          ActionDispatch::Journey::Nodes::Cat.new(
            ActionDispatch::Journey::Nodes::Slash.new("/"),
            ActionDispatch::Journey::Nodes::Cat.new(
              ActionDispatch::Journey::Nodes::Literal.new("v1"),
              ActionDispatch::Journey::Nodes::Cat.new(
                ActionDispatch::Journey::Nodes::Slash.new("/"),
                ActionDispatch::Journey::Nodes::Cat.new(
                  ActionDispatch::Journey::Nodes::Literal.new("books"),
                  ActionDispatch::Journey::Nodes::Cat.new(
                    ActionDispatch::Journey::Nodes::Slash.new("/"),
                    ActionDispatch::Journey::Nodes::Cat.new(
                      ActionDispatch::Journey::Nodes::Symbol.new(":id"),
                      ActionDispatch::Journey::Nodes::Group.new(
                        ActionDispatch::Journey::Nodes::Dot.new(".")
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    end
    let(:parameters_context) { [ ] }

    it "returns path string" do
      is_expected.to eq "/api/v1/books/{id}"
      expect(parameters_context).to eq [{name: "id"}]
    end
  end
end
