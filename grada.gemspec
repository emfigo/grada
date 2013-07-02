Gem::Specification.new do |s|
  s.name           = 'grada'
  s.version        = '1.1.1'
  s.date           = '2013-06-20'
  s.summary        = 'GraDA'
  s.description    = 'Graphic Data Analysis gem'
  s.authors        = ['Enrique Figuerola']
  s.email          = 'hard_rock15@msn.com'
  s.files          = ['lib/grada.rb']
  s.require_paths  = ['lib']
  s.homepage       = 'https://github.com/emfigo/grada'

  s.add_development_dependency(%q<rspec>, [">= 2.11.0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_dependency(%q<gnuplot>, ['>= 2.6.2'])
end
