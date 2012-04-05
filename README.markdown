# Sax Stream

An XML parsing library using Nokogiri's Sax Parser which uses an object mapper to build objects from XML nodes and lets you use them as they are built, rather than waiting until the file is fully parsed.

The two main goals of this process are:

1. To avoid loading the entire XML file stream into memory at once.
2. To avoid loading all the mapped objects into memory simultaneously.

This is currently only for XML importing. Supporting exporting too would be nice if I need it.

## Status

Currently development has only just started, the library is useable for minimal experimental use cases, but don't use it for production.

## Installation

Not yet packed as a gem, install it from github.

## Usage

### Define your mapper classes

These are object definitions that you would like to extract from the XML. I recommend sticking with fairly thin classes for these. In the past, I've used similar libraries like ROXML and inherited my mapping classes from ActiveRecord or other base classes, and ended up with poorly designed code. Your mapper classes should do one thing only, provide access to structured in-memory data which can be streamed from XML.

```
require 'sax_stream/mapper'

class Product
  include SaxStream::Mapper

  node 'product'
  map :id,             :to => '@id'
  map :status,         :to => '@status'
  map :name_confirmed, :to => 'name/@confirmed'
  map :name,           :to => 'name'
end
```

In this example, Product is a mapping class. It maps to an xml node named "product". Each "attribute" on this product object is defined using the "map" class method. The :to option uses a syntax which is similar to XPath, but not the same. Slashes seperate levels in the XML node heirarchy. If the data is in an attribute, this is designated by the @symbol. Obviously attributes must be at the end of the path, as they have no children. This product class is used to parse XML like this:

```
<?xml version="1.0" encoding="UTF-8"?>
<product id="123" status="new">
  <name confirmed="yes">iPhone 5G</name>
</product>
```

### Run the parser

The parser object must be supplied with a collector and an array of mapping classes to use.

```
require 'sax_stream/parser'

collector = SaxStream::NaiveCollector.new
parser = SaxStream::Parser.new(collector, [Product])

parser.parse_stream(File.open('products.xml'))
```

The purpose of the collector is to be given the object once it has been built. It's basically any object which supports the "<<" operator (so yes, an Array works as a collector). SaxStream includes a NaiveCollector which you can use, but it's so named to remind you that this probably isn't what you want to do.

If you use the example above, you will get some memory benefits over using a library like ROXML or HappyMapper, because the XML file is at least being processed as a stream, and not held in memory. This lets you process a very large file. However, the naive collector is holding all the created objects in memory, so as you parse the file, this gets bigger.

To get the full benefits of this library, supply a collector which does something else with the objects as they are received, such as save them to a database.

I plan to supply a batching collector which will collect a certain number of objects before passing them off to another collector you supply, so you can save objects in batches of 100 or whatever is optimal for your application.

## Author

Craig Ambrose
http://www.craigambrose.com
