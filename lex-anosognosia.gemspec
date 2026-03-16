# frozen_string_literal: true

require_relative 'lib/legion/extensions/anosognosia/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-anosognosia'
  spec.version       = Legion::Extensions::Anosognosia::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Anosognosia'
  spec.description   = 'Cognitive deficit awareness modeling for brain-modeled agentic AI — tracks blind spots, awareness gaps, and calibration'
  spec.homepage      = 'https://github.com/LegionIO/lex-anosognosia'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-anosognosia'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-anosognosia'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-anosognosia'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-anosognosia/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-anosognosia.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
