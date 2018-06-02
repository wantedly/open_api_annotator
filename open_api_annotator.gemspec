
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

  spec.add_dependency "open_api", ">= 0.3.3"
  spec.add_dependency "active_model_serializers", "~> 0.10.0"

  rails_versions = ['>= 4.1', '< 6']
  spec.add_dependency "actionpack", rails_versions
  spec.add_dependency "railties", rails_versions

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "simplecov"
end
