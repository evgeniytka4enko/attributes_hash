# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attributes_hash/version'

Gem::Specification.new do |spec|
  spec.name          = "attributes_hash"
  spec.version       = AttributesHash::VERSION
  spec.authors       = ["Evgeniy Tkachenko"]
  spec.email         = ["evgeniytka4enko@gmail.com"]

  spec.summary       = spec.description
  spec.description   = "Creates a hash with specific attributes"
  spec.homepage      = "https://github.com/evgeniytka4enko/attributes_hash"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "faker"

  spec.add_dependency "activemodel", ">= 4.0"
  spec.add_dependency "activerecord", ">= 4.0"
end
