Gem::Specification.new do |s|
  s.name = 'sax_stream'
  s.version = '0.1.0'
  s.summary = 'A streaming XML parser which builds objects and passes them to a collecter as they are ready'
  s.authors     = ["Craig Ambrose"]
  s.email       = ["craig@craigambrose.com"]
  s.homepage    = "http://github.com/craigambrose/sax_stream"

  s.add_dependency('nokogiri', '>= 1.4.0')

  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README.markdown)
  s.require_path = 'lib'
end