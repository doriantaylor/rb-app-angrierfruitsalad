# -*- mode: enh-ruby; coding: utf-8 -*-
require_relative 'lib/app/angrierfruitsalad/version'

Gem::Specification.new do |spec|
  spec.name        = "app-angrierfruitsalad"
  spec.version     = App::AngrierFruitSalad::VERSION
  spec.authors     = ["Dorian Taylor"]
  spec.email       = ["code@doriantaylor.com"]
  spec.homepage    = 'https://github.com/doriantaylor/rb-app-angrierfruitsalad'
  spec.summary     = 'Leaner. Angrier. Fruitier.'
  spec.description = <<~DESC
  The Angrier Fruit Salad is a reprise of the Angry Fruit Salad, a
  demonstration project from many years ago.
  DESC

  # why is this duplicated anyway?
  spec.metadata["homepage_uri"] = spec.homepage

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
      end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # le ruby
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # stuff for testing
  # ???

  # stuff we use
  spec.add_runtime_dependency 'rdf', '~> 3.1.1'

  # stuff i wrote
  spec.add_runtime_dependency 'rdf-kv', '>= 0.1.0'

end
