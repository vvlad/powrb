# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dev_machine/version'

Gem::Specification.new do |gem|
  gem.name          = "dev_machine"
  gem.version       = DevMachine::VERSION
  gem.authors       = ["Vlad Verestiuc"]
  gem.email         = ["vlad.verestiuc@me.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rubydns"
  gem.add_dependency "thin"
  gem.add_dependency "json"
  gem.add_dependency "eventmachine_httpserver"

end
