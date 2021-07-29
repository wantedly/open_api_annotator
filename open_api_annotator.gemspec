
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "open_api_annotator/version"

Gem::Specification.new do |spec|
  spec.name          = "open_api_annotator"
  spec.version       = OpenApiAnnotator::VERSION
  spec.authors       = ["Kent Nagata"]
  spec.email         = ["ngtknt@me.com"]

  spec.summary       = %q{OpenApi spec generation by bottom-up.}
  spec.description   = %q{OpenApiAnnotator realizes to generate OpenApi spec by annotating to Controller and ActiveModelSerializer.}
  spec.homepage      = "https://github.com/ngtk/open_api_annotator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "open_api", ">= 0.5.0"
  spec.add_dependency "active_model_serializers", "~> 0.10.0"

  rails_versions = ['>= 5.0', '< 6.2']
  spec.add_dependency "actionpack", rails_versions
  spec.add_dependency "railties", rails_versions

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  # Pin to 1.17 due to https://github.com/codeclimate/test-reporter/issues/413
  spec.add_development_dependency "simplecov", "~> 0.17.0"
  spec.add_development_dependency "bump"
end
