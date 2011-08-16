# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "real_hq_shared//version"

Gem::Specification.new do |s|
  s.name        = "real_hq_shared/"
  s.version     = RealHqShared/::VERSION
  s.authors     = ["Gavin Todes"]
  s.email       = ["gavin.todes@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Real HQ shared code}
  s.description = %q{A gem that includes code shared across Real HQ apps}

  s.rubyforge_project = "real_hq_shared/"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]  
  
  s.add_dependency('httparty')
end
