lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beyonic/version'

Gem::Specification.new do |spec|
  spec.name          = 'beyonic'
  spec.version       = Beyonic::VERSION
  spec.authors       = ['Oleg German', 'Luke Kyohere']
  spec.email         = ['oleg.german@gmail.com', 'luke@beyonic.com']
  spec.summary       = 'Ruby library for the beyonic.com api'
  spec.description   = 'Beyonic.com makes enterprise payments to mobile easy. Details: http://beyonic.com'
  spec.homepage      = 'http://support.beyonic.com/api/'
  spec.license       = 'MIT'

  spec.files         = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', '*.md']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rest-client', '~> 2.1.0'
  spec.add_runtime_dependency 'oj', '~> 2.11'
  spec.add_runtime_dependency 'addressable', '~> 2.7'

  spec.add_development_dependency 'bundler', '~> 2.1.4'
  spec.add_development_dependency 'rake', '~> 13.0.1'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.2.0'
  spec.add_development_dependency 'webmock', '~> 3.8.3'
  spec.add_development_dependency 'simplecov', '~> 0.18.5'
  spec.add_development_dependency 'vcr', '~> 6.0.0'
end
