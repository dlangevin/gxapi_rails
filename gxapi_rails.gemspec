$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gxapi/version"

Gem::Specification.new do |s|
  s.name = "gxapi_rails"
  s.version = Gxapi::VERSION

  s.authors = ["Dan Langevin"]
  s.email = "dan.langevin@lifebooker.com"

  s.homepage = "http://github.com/LifebookerInc/gxapi_rails"
  s.require_paths = ["lib"]

  s.summary = "Google Analytics"
  s.description = "Google Analytics and integration"


 s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency(%q<activesupport>, [">= 0"])
  s.add_dependency(%q<celluloid>, [">= 0"])
  s.add_dependency(%q<rest-client>, [">= 0"])
  s.add_dependency(%q<json>, [">= 0"])
  s.add_dependency(%q<google-api-client>, [">= 0"])

end

