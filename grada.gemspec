Gem::Specification.new do |s|
  s.name           = 'grada'
  s.version        = '3.0.0'
  s.date           = "#{Time.now.strftime("%Y-%m-%-d")}"
  s.summary        = 'GraDA'
  s.license        = 'MIT'
  s.description    = 'Graphic Data Analysis gem'
  s.authors        = ['Enrique Figuerola']
  s.email          = 'hard_rock15@msn.com'
  s.files          = ['lib/grada.rb', 'lib/grada/graph.rb', 'lib/grada/types/default_base.rb', 'lib/grada/types/default.rb', 'lib/grada/types/gnuplot.rb', 'lib/grada/types/heat_map.rb', 'lib/grada/types/histogram.rb']
  s.require_paths  = ['lib']
  s.homepage       = 'https://github.com/emfigo/grada'

  s.add_development_dependency(%q<rspec>, [">= 2.11.0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
end
