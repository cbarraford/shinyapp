# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shinyapp/version'

Gem::Specification.new do |spec|
  spec.name          = "shinyapp"
  spec.version       = Shinyapp::VERSION
  spec.authors       = ["Chad Barraford"]
  spec.email         = ["cbarraford@gmail.com"]
  spec.description   = %q{Sinatra gem to run shinyapp}
  spec.summary       = %q{Run shiny app frontend}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  %w( thin sinatra sinatra-contrib bcrypt
      haml rest-client json ).each do |gem|
    spec.add_dependency gem
  end

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
