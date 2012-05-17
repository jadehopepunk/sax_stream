Gem::Specification.new do |s|
  s.name = 'sax_stream'
  s.version = '1.0.3'
  s.summary = 'A streaming XML parser which builds objects and passes them to a collecter as they are ready'
  s.description = 'A streaming XML parser which builds objects and passes them to a collecter as they are ready. Based upon Nokogiri SAX parsing functionality.'
  s.authors     = ["Craig Ambrose"]
  s.email       = ["craig@craigambrose.com"]
  s.homepage    = "http://github.com/craigambrose/sax_stream"

  s.add_dependency('nokogiri', '>= 1.5.2')

  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README.markdown)
  s.require_path = 'lib'
end