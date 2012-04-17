# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "destroyer/version"

Gem::Specification.new do |s|
  s.name        = "destroyer"
  s.version     = Destroyer::VERSION
  s.authors     = ["Sergio Figueroa"]
  s.email       = ["sergio.figueroa@crowdint.com"]
  s.homepage    = ""
  s.summary     = %q{Deletes records without instantiating the records first}
  s.description = %q{Deletes records(without instantiating the records first) based on a block(which returns an array of ids) given and also recursively deletes all their associated records if they are marked as :dependent => :destroy. It is useful for background processing.}

  s.rubyforge_project = "destroyer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord', '~> 3.0.0'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec'
end
