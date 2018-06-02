require 'spec_helper'
require 'action_controller'

RSpec.describe OpenApiAnnotator::PathsBuilder do
  describe "#build" do
    subject { builder.build }

    let(:builder) { described_class.new }
    let(:routes) do
      [
        OpenApiAnnotator::Route.new(
          http_verb: "GET",
          path: "/api/v1/books",
          controller_name: "api/v1/books",
          action_name: "index",
        ),
        OpenApiAnnotator::Route.new(
          http_verb: "GET",
          path: "/api/v1/books/{id}",
          controller_name: "api/v1/books",
          action_name: "show",
        ),
      ]
    end
    let(:some_path_item) { double(:path_item) }

    before do
      allow_any_instance_of(OpenApiAnnotator::RoutesFinder).to receive(:find_all).and_return(routes)
      allow(builder).to receive(:build_path_item).and_return(some_path_item)
    end

    it "returns an hash which has a String as key and an OpenApi::Paths as value" do
      is_expected.to eq OpenApi::Paths.new(
        "/api/v1/books/{id}": some_path_item,
        "/api/v1/books": some_path_item,
      )
    end
  end

  describe "#build_path_item" do
    subject { described_class.new.send(:build_path_item, routes) }

    before do
      stub_const("Api::V1::BooksController", Class.new(ActionController::Base))
      stub_const("Book", Class.new)

      allow(Api::V1::BooksController).to receive(:type_hash).and_return(
        {
          index: [Book],
          show: Book,
          update: Book,
        }
      )
    end

    context "when path has multiple operations" do
      let(:routes) do
        [
          OpenApiAnnotator::Route.new(
            http_verb: "GET",
            path: "/api/v1/books/{id}",
            controller_name: "api/v1/books",
            action_name: "show",
          ),
          OpenApiAnnotator::Route.new(
            http_verb: "PATCH",
            path: "/api/v1/books/{id}",
            controller_name: "api/v1/books",
            action_name: "update",
          ),
        ]
      end

      it "returns OpenApi::PathItem" do
        is_expected.to eq OpenApi::PathItem.new(
          "GET": OpenApi::Operation.new(
            responses: OpenApi::Responses.new(
              "200": OpenApi::Response.new(
                description: "Returns Book",
                content: {
                  "application/json" => OpenApi::MediaType.new(
                    schema: OpenApi::Reference.new(ref: "#/components/schemas/Book"),
                  )
                }
              )
            )
          ),
          "PATCH": OpenApi::Operation.new(
            responses: OpenApi::Responses.new(
              "200": OpenApi::Response.new(
                description: "Returns Book",
                content: {
                  "application/json" => OpenApi::MediaType.new(
                    schema: OpenApi::Reference.new(ref: "#/components/schemas/Book"),
                  )
                }
              )
            )
          )
        )
      end
    end

    context "when media type is array of model" do
      let(:routes) do
        [
          OpenApiAnnotator::Route.new(
            http_verb: "GET",
            path: "/api/v1/books",
            controller_name: "api/v1/books",
            action_name: "index",
          ),
        ]
      end

      it "returns OpenApi::PathItem" do
        is_expected.to eq OpenApi::PathItem.new(
          get: OpenApi::Operation.new(
            responses: OpenApi::Responses.new(
              "200": OpenApi::Response.new(
                description: "Returns array of Book",
                content: {
                  "application/json" => OpenApi::MediaType.new(
                    schema: OpenApi::Schema.new(
                      type: "array",
                      items: OpenApi::Reference.new(ref: "#/components/schemas/Book"),
                    )
                  )
                }
              )
            )
          )
        )
      end
    end
  end
end
