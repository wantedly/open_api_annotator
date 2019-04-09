# OpenApiAnnotator [![Gem Version](https://badge.fury.io/rb/open_api_annotator.svg)](https://badge.fury.io/rb/open_api_annotator) [![Build Status](https://travis-ci.org/ngtk/open_api_annotator.svg?branch=master)](https://travis-ci.org/ngtk/open_api_annotator) [![Maintainability](https://api.codeclimate.com/v1/badges/8be7a273496459c62190/maintainability)](https://codeclimate.com/github/ngtk/open_api_annotator/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/8be7a273496459c62190/test_coverage)](https://codeclimate.com/github/ngtk/open_api_annotator/test_coverage)

OpenApiAnnotator realizes to generate OpenAPI spec by annotating to controllers and serializers.
If you use ActiveModelSerializer, this is the best way to generate OpenAPI spec.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'open_api_annotator'
```

## Usage

Annotating controllers and serializers, you can generate OpenAPI spec file from these.
Things you have to do are three below:

1. Configure API meta information
1. Annotate controllers
1. Annotate serializers

### 1. Configure API meta information
You have to set API meta information like:

```rb
# config/initializers/open_api_annotator.rb
OpenApiAnnotator.configure do |config|
  config.info = OpenApi::Info.new(title: "Book API", version: "1")
  config.destination_path = Rails.root.join("api_spec.yml")
  config.path_regexp = /\Aapi\/v1\// # If you want to restrict a path to create
end
```


### 2. Annotate controller
To define an entity of an endpoint, call the method `endpoint` in the previous line of an action method. It takes entity expression as the first arg. Entity expression is a model class or an array that contains only one model class.

```rb
class Api::V1::BooksController
  endpoint [Book] # 👈It means an array of Book
  def index
    books = Book.limit(10)
    render json: books
  end

  endpoint Book # 👈Just a Book
  def show
    book = Book.find(params[:id])
    render json: book
  end

  endpoint Book # 👈Just a Book
  def update
     book = Book.find(params[:id])
     book.update!(book_params)
     render json: book
  end
end
```

### 3. Annotate serializer
To define an schema in components, set `type`, `format`, `nullable` as each field option.

```rb
class BookSerializer < ApplicationSerializer
  attribute :title, type: :string, nullable: false
  attribute :published_at, type: :string, format: :"date-time", nullable: true

  has_many :authors, type: [Author], nullable: false
  has_one :cover_image, type: CoverImage, nullable: true
  belongs_to :publisher, type: Publisher, nullable: false
end
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number using `bundle exec bump patch`(or minor, major), and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ngtk/open_api_annotator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OpenApiAnnotator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ngtk/open_api_annotator/blob/master/CODE_OF_CONDUCT.md).
