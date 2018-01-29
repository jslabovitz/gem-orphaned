#encoding: utf-8

require 'rubygems/command'
require_relative 'lib/gem-orphaned/version'

Gem::Specification.new do |s|
  s.name          = 'gem-orphaned'
  s.version       = Gem::Commands::OrphanedCommand::VERSION
  s.summary       = %q{Show orphaned gems}
  s.description   = %q{A Ruby gem which shows orphaned gems.}
  s.author        = 'John Labovitz'
  s.email         = 'johnl@johnlabovitz.com'
  s.homepage      = 'https://github.com/jslabovitz/gem-orphaned.git'
  s.license       = 'MIT'
  s.files         = `git ls-files`.split($/)
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path  = 'lib'

  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'rubygems-tasks', '~> 0.2'
end