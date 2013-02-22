# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "sharp"
  gem.version       = "0.0.2"
  gem.authors       = ["Paul Barry"]
  gem.email         = ["mail@paulbarry.com"]
  gem.description   = %q{A web framework}
  gem.summary       = %q{A web framework}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "activesupport"
  gem.add_runtime_dependency "rack-router"
  gem.add_runtime_dependency "rack-action"
end
