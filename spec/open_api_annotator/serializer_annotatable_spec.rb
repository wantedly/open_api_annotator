require 'spec_helper'
require 'active_model_serializers'

RSpec.describe OpenApiAnnotator::SerializerAnnotatable do
  before do
    # Annotations without `type:` are warned via Rails.logger
    allow(Rails).to receive(:logger).and_return(Logger.new(nil))
    stub_const("AuthorSerializer", Class.new(ActiveModel::Serializer) { include OpenApiAnnotator::SerializerAnnotatable })
    stub_const("BookSerializer", Class.new(ActiveModel::Serializer) { include OpenApiAnnotator::SerializerAnnotatable })
  end

  describe ".open_api_has_many_associations" do
    subject { BookSerializer.open_api_has_many_associations }

    before { BookSerializer.has_many :authors, nullable: false, serializer: AuthorSerializer }

    it "returns the resource name of the serializer as an array type" do
      is_expected.to eq [OpenApiAnnotator::Association.new(:authors, ["Author"], false)]
    end
  end

  describe ".open_api_has_one_associations" do
    subject { BookSerializer.open_api_has_one_associations }

    before { BookSerializer.has_one :author, nullable: false, serializer: AuthorSerializer }

    it "returns the resource name of the serializer as a single type" do
      is_expected.to eq [OpenApiAnnotator::Association.new(:author, "Author", false)]
    end
  end

  describe ".open_api_belongs_to_associations" do
    subject { BookSerializer.open_api_belongs_to_associations }

    before { BookSerializer.belongs_to :author, nullable: false, serializer: AuthorSerializer }

    it "returns the resource name of the serializer as a single type" do
      is_expected.to eq [OpenApiAnnotator::Association.new(:author, "Author", false)]
    end
  end
end
