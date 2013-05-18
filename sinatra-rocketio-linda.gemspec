# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinatra/rocketio/linda/version'

Gem::Specification.new do |spec|
  spec.name          = "sinatra-rocketio-linda"
  spec.version       = Sinatra::RocketIO::Linda::VERSION
  spec.authors       = ["Sho Hashimoto"]
  spec.email         = ["hashimoto@shokai.org"]
  spec.description   = %q{Linda implementation on Sinatra RocketIO}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/shokai/sinatra-rocketio-linda"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).reject{|i| i == "Gemfile.lock" }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "thin"
  spec.add_development_dependency "haml"

  spec.add_dependency "linda"
  spec.add_dependency "sinatra-rocketio"
  spec.add_dependency "event_emitter"
  spec.add_dependency "sinatra"
end
