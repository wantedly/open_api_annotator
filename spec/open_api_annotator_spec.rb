RSpec.describe OpenApiAnnotator do
  it "has a version number" do
    expect(OpenApiAnnotator::VERSION).not_to be nil
  end

  describe ".configure" do
    subject do
      OpenApiAnnotator.configure do |config|
        config.info = OpenApi::Info.new(title: "Book API", version: "1")
        config.destination_path = "path/to/spec.yml"
        config.path_regexp = /\Aapi\/v1\//
        config.application_controller_class_name = "BaseController"
        config.application_serializer_class_name = "BaseSerializer"
      end
    end

    before do
      stub_const("BaseController", Class.new)
      stub_const("BaseSerializer", Class.new)
    end

    it "sets config" do
      subject
      config = OpenApiAnnotator.config
      expect(config.destination_path).to eq "path/to/spec.yml"
      expect(config.path_regexp).to eq /\Aapi\/v1\//
      expect(config.application_controller_class).to eq BaseController
      expect(config.application_serializer_class).to eq BaseSerializer
    end
  end
end
