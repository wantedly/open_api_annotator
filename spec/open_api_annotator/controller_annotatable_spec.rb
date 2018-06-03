require 'spec_helper'

RSpec.describe OpenApiAnnotator::ControllerAnnotatable do
  describe "#endpoint" do
    subject do
      class BooksController
        extend OpenApiAnnotator::ControllerAnnotatable

        endpoint Book
        def show
          # some code
        end

        endpoint [Book]
        def index
          # some code
        end
      end
    end

    before do
      stub_const("Book", Class.new)
    end

    it "sets endpoint_hash" do
      subject
      expect(BooksController.endpoint_hash).to match({ show: Book, index: [Book] })
    end
  end
end
