% cat freewill.gemspec
Gem::Specification.new do |s|
  s.name        = 'my_enumerator'
  s.version     = '0.0.0'
  s.date        = '2015-10-11'
  s.summary     = 'My Enumerator'
  s.description = 'My own implementation of Enumerable and Enumerator'
  s.authors     = ['Juan C. Pazmino']
  s.email       = 'juankpro@outlook.com'
  s.homepage    = 'http://rubygems.org/gems/my_enumerator'
  s.files       = ['lib/my_enumerable.rb', 'lib/my_enumerator.rb', 'Rakefile']
  s.test_files  = ['test/test_enumerator.rb', 'test/test_enumerable.rb']

  s.add_development_dependency 'minitest', ['~> 5.8.1']
end
