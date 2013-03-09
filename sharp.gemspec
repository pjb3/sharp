# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "sharp"
  gem.version       = "0.3.1"
  gem.authors       = ["Paul Barry"]
  gem.email         = ["mail@paulbarry.com"]
  gem.description   = %q{A Ruby and Rack-based web framework}
  gem.summary       = %q{A Ruby and Rack-based web framework}
  gem.homepage      = "http://github.com/pjb3/sharp"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "activesupport"
  gem.add_runtime_dependency "curtain"
  gem.add_runtime_dependency "rack-router"
  gem.add_runtime_dependency "rack-action"
end
