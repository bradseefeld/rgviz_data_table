# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rgviz/data_table/version"

Gem::Specification.new do |s|
  s.name        = "rgviz_data_table"
  s.version     = Rgviz::DataTable::VERSION
  s.authors     = ["Brad Seefeld"]
  s.email       = ["brad@urbaninfluence.com"]
  s.homepage    = ""
  s.summary     = %q{An implemention of DataTable for Google Visualization.}
  s.description = %q{A DataTable that provides Google Visualization query execution against data that may not be accessible by ActiveRecord.}

  s.rubyforge_project = "rgviz_data_table"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
