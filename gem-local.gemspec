# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "gem-local"
  spec.version       = "0.1.0"
  spec.authors       = ["Chris Keele"]
  spec.email         = ["dev@chriskeele.com"]

  spec.summary       = "A configuration manager for bundler's local gem settings."
  spec.description   = "The `gem local` command allows you to track, change, update per-project usage of `bundle config local.<gem>` settings."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
