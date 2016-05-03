# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require 'gem/local/version'

Gem::Specification.new do |spec|
  spec.name          = "gem-local"
  spec.version       = "0.1.0"#Gem::Local::VERSION
  spec.authors       = ["Chris Keele"]
  spec.email         = ["dev@chriskeele.com"]

  spec.summary       = "Toggles bundler's local gem configuration for you."
  spec.description   = "The `gem local` command allows you to save, toggle, and recall per-project usage of `bundle config local.<gem>` settings."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
