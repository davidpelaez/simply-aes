# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simply-aes/version'

Gem::Specification.new do |spec|
  spec.name          = 'simply-aes'
  spec.version       = SimplyAES::VERSION
  spec.authors       = ['Ryan Biesemeyer']
  spec.email         = ['ryan@simplymeasured.com']
  spec.summary       = 'Simple AES-256-driven encryption'
  spec.homepage      = 'https://github.com/simplymeasured/simply-aes'
  spec.license       = 'Apache 2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'ruby-appraiser-rubocop'
end
