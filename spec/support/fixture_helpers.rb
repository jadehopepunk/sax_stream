def open_fixture(name)
  File.open(File.join(File.dirname(__FILE__), "../fixtures/#{name}.xml"))
end
