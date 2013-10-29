# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jira-remotelinker/version'

Gem::Specification.new do |spec|
  spec.name          = 'jira-remotelinker'
  spec.version       = JiraRemotelinker::VERSION
  spec.authors       = ['Charlie Sharpsteen']
  spec.email         = ['source@sharpsteen.net']
  spec.description   = %q{A small command line tool for creating remote links through the JIRA REST API}
  spec.summary       = %q{This tool reads in issue link information from CSV and creates remote links using v2 of the JIRA REST API.}
  spec.homepage      = 'https://github.com/Sharpie/jira-remotelinker'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  spec.executables   = ['jira-remotelinker']

  spec.add_runtime_dependency 'methadone', '~> 1.3.0'
  spec.add_runtime_dependency 'httparty', '~> 0.12.0'
  spec.add_runtime_dependency 'progressbar'
end
