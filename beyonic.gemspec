# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beyonic/version'

Gem::Specification.new do |spec|
  spec.name          = "beyonic"
  spec.version       = Beyonic::VERSION
  spec.authors       = ['Oleg German', 'Luke Kyohere']
  spec.email         = ['oleg.german@gmail.com', 'luke@beyonic.com']
  spec.summary       = %q{Ruby library for the beyonic.com api}
  spec.description   = %q{Beyonic.com makes enterprise payments to mobile easy. Details: http://beyonic.com}
  spec.homepage      = "http://support.beyonic.com/api/"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "oj", "~> 2.11"
  spec.add_runtime_dependency "addressable"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-collection_matchers"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "vcr"
end
