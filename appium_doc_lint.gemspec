require_relative 'lib/appium_doc_lint'

Gem::Specification.new do |s|
  # 1.8.x is not supported
  s.required_ruby_version = '>= 1.9.3'

  s.name = 'appium_doc_lint'
  s.version = Appium::Lint::VERSION
  s.date = Appium::Lint::DATE
  s.license = 'http://www.apache.org/licenses/LICENSE-2.0.txt'
  s.description = s.summary = 'Appium Doc Lint'
  s.description += '.' # avoid identical warning
  s.authors = s.email = [ 'code@bootstraponline.com' ]
  s.homepage = 'https://github.com/appium/appium_doc_lint' # published as appium_doc_lint
  s.require_paths = [ 'lib' ]

  s.add_development_dependency 'rake', '~> 10.3.1'
  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'posix-spawn', '~> 0.3.8'

  s.executables   = [ 'appium_doc_lint' ]
  s.files = `git ls-files`.split "\n"
end
