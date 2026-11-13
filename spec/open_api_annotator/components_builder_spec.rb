require 'spec_helper'
require 'active_model_serializers'

RSpec.describe OpenApiAnnotator::ComponentsBuilder do
  describe "#build" do
    subject { builder.build }

    let(:builder) { described_class.new }

    let(:has_many_association) { OpenApiAnnotator::Association.new("authors", [Author], false) }
    let(:has_one_association) { OpenApiAnnotator::Association.new("cover_image", CoverImage, true) }
    let(:belongs_to_association) { OpenApiAnnotator::Association.new("publisher", Publisher, false) }
    let(:attribute) { OpenApiAnnotator::Attribute.new("published_at", "string", "date-time", false) }
    let(:array_attribute) { OpenApiAnnotator::Attribute.new("tags", ["string"], nil, false) }
    let(:id_attribute) { OpenApiAnnotator::Attribute.new("id", "number", nil, false) }

    before do
      stub_const("BookSerializer", Class.new(ActiveModel::Serializer))
      stub_const("Author", Class.new)
      stub_const("CoverImage", Class.new)
      stub_const("Publisher", Class.new)

      allow(builder).to receive(:fetch_all_serializers).and_return([BookSerializer])

      allow(BookSerializer).to receive(:open_api_has_many_associations).and_return([has_many_association])
      allow(BookSerializer).to receive(:open_api_has_one_associations).and_return([has_one_association])
      allow(BookSerializer).to receive(:open_api_belongs_to_associations).and_return([belongs_to_association])
      allow(BookSerializer).to receive(:open_api_attributes).and_return([attribute, array_attribute, id_attribute])
      allow(BookSerializer).to receive(:open_api_resource_name).and_return("Book")
    end

    it "returns components" do
      is_expected.to eq OpenApi::Components.new(
        schemas: {
          "Book" => OpenApi::Schema.new(
            type: "object",
            properties: {
              id: OpenApi::Schema.new(type: "number", format: nil),
              published_at: OpenApi::Schema.new(type: "string", format: "date-time"),
              tags: OpenApi::Schema.new(
                type: "array",
                items: OpenApi::Schema.new(type: "string", format: nil)
              ),
              authors: OpenApi::Schema.new(
                type: "array",
                items: OpenApi::Reference.new(ref: "#/components/schemas/Author"),
              ),
              cover_image: OpenApi::Schema.new(
                nullable: true,
                allOf: [OpenApi::Reference.new(ref: "#/components/schemas/CoverImage"),]
              ),
              publisher: OpenApi::Reference.new(ref: "#/components/schemas/Publisher"),
            },
          )
        }
      )
    end

    context "when always_required_fields option is supplied" do
      before do
        allow(OpenApiAnnotator.config).to receive(:always_required_fields).and_return [:id]
      end

      it "returns components" do
        is_expected.to eq OpenApi::Components.new(
          schemas: {
            "Book" => OpenApi::Schema.new(
              type: "object",
              properties: {
                id: OpenApi::Schema.new(type: "number", format: nil),
                published_at: OpenApi::Schema.new(type: "string", format: "date-time"),
                tags: OpenApi::Schema.new(
                  type: "array",
                  items: OpenApi::Schema.new(type: "string", format: nil)
                ),
                authors: OpenApi::Schema.new(
                  type: "array",
                  items: OpenApi::Reference.new(ref: "#/components/schemas/Author"),
                ),
                cover_image: OpenApi::Schema.new(
                  nullable: true,
                  allOf: [OpenApi::Reference.new(ref: "#/components/schemas/CoverImage"),]
                ),
                publisher: OpenApi::Reference.new(ref: "#/components/schemas/Publisher"),
              },
              required: [:id]
            )
          }
        )
      end
    end

    context "when has_many associations are annotated with non-array types" do
      let(:class_has_many_association) { OpenApiAnnotator::Association.new("logs", Log, true) }
      let(:string_has_many_association) { OpenApiAnnotator::Association.new("notes", "Note", true) }

      before do
        # Like an ActiveRecord model, `first` would run a query
        stub_const("Log", Class.new { def self.first; raise "Log.first must not be called"; end })
        allow(BookSerializer).to receive(:open_api_has_many_associations).and_return([class_has_many_association, string_has_many_association, has_many_association])
      end

      it "skips only the associations with warnings" do
        expect { subject }.to output(/Skipped BookSerializer#logs: .* but got Log\..*Skipped BookSerializer#notes: .* but got Note\./m).to_stderr
        expect(subject.schemas["Book"].properties.keys).to contain_exactly(:id, :published_at, :tags, :authors, :cover_image, :publisher)
      end
    end

    context "when a has_many association is annotated with an empty array" do
      let(:empty_array_has_many_association) { OpenApiAnnotator::Association.new("logs", [], true) }

      before do
        allow(BookSerializer).to receive(:open_api_has_many_associations).and_return([empty_array_has_many_association, has_many_association])
      end

      it "skips only the association with a warning" do
        expect { subject }.to output(/Skipped BookSerializer#logs/).to_stderr
        expect(subject.schemas["Book"].properties.keys).to contain_exactly(:id, :published_at, :tags, :authors, :cover_image, :publisher)
      end
    end
  end

end
