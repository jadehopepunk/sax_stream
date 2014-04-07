# Sax Stream

[![Build Status](https://secure.travis-ci.org/craigambrose/sax_stream.png)](http://travis-ci.org/craigambrose/sax_stream)

An XML parsing library using Nokogiri's Sax Parser which uses an object mapper to build objects from XML nodes and lets you use them as they are built, rather than waiting until the file is fully parsed.

The two main goals of this process are:

1. To avoid loading the entire XML file stream into memory at once.
2. To avoid loading all the mapped objects into memory simultaneously.

This library handles both importing and exporting, but at present no steps have been taken to conserve memory when exporting XML. Using this library for export is comparable to ROXML or Happymapper (and is heavily based on ROXML's implementation).

## Status

Supports basic XML examples. Still needs to be tested with more complex XML.
Even slightly invalid XML is likely to cause an immediate exception.

## Installation

gem install 'sax_stream'

## Usage

### Define your mapper classes

These are object definitions that you would like to extract from the XML. I recommend sticking with fairly thin classes for these. In the past, I've used similar libraries like ROXML and inherited my mapping classes from ActiveRecord or other base classes, and ended up with poorly designed code. Your mapper classes should do one thing only, provide access to structured in-memory data which can be streamed from XML.

```ruby
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

In this example, Product is a mapping class. It maps to an xml node named "product". Each "attribute" on this product object is defined using the "map" class method. The :to option uses a syntax which is similar to XPath, but not the same. Slashes seperate levels in the XML node hierarchy. If the data is in an attribute, this is designated by the @symbol. Obviously attributes must be at the end of the path, as they have no children. This product class is used to parse XML like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<product id="123" status="new">
  <name confirmed="yes">iPhone 5G</name>
</product>
```

All data written to your object from the XML will be a string, unless you convert it. To specify a converter on a field mapping, use the :as option.

```ruby
  map :created_at, :to => '@createdAt', :as => DateTime
```

The :as option can be handed any object which supports a "parse" method, which takes a string as it's first and only parameter, and outputs the converted value. It looks particularly good if this converter is also a class, which indicates that the converted value will be an instance of this class.

This library doesn't include any converters, so the DateTime example above wont work out of the box. However, if you are using the active_support gem, then Date, Time & DateTime will all work as values for :as. If you're dealing with a file format that formats dates (or some other object) in an unusual way, simply define your own.

```ruby
class UnusualDate
  def self.parse(string)
    # convert this unusual string to a Date
    # No need to check for nil, sax_stream does that
  end
end
```

### Importing XML: Run the parser

The parser object must be supplied with a collector and an array of mapping classes to use.

```ruby
require 'sax_stream/parser'
require 'sax_stream/collectors/naive_collector'

collector = SaxStream::Collectors::NaiveCollector.new
parser = SaxStream::Parser.new(collector, [Product])

parser.parse_stream(File.open('products.xml'))
```

The purpose of the collector is to be given the object once it has been built. It's basically any object which supports the "<<" operator (so yes, an Array works as a collector). SaxStream includes a NaiveCollector which you can use, but it's so named to remind you that this probably isn't what you want to do.

If you use the example above, you will get some memory benefits over using a library like ROXML or HappyMapper, because the XML file is at least being processed as a stream, and not held in memory. This lets you process a very large file. However, the naive collector is holding all the created objects in memory, so as you parse the file, this gets bigger.

To get the full benefits of this library, supply a collector which does something else with the objects as they are received, such as save them to a database.

I plan to supply a batching collector which will collect a certain number of objects before passing them off to another collector you supply, so you can save objects in batches of 100 or whatever is optimal for your application.

### Exporting XML: Call to_xml

No parser or collector object is used to export XML. Simply call to_xml on the root object. The exporter will expect data to be in the same place it was imported to. It will look in attributes for data for this object, and relations to find associated objects. If you defined custom setters on your object to manipulate the values, then you may need to also supply custom getters.

## Credits

Author: [Craig Ambrose](http://www.craigambrose.com)

Initial development sponsored by: [List Globally](http://www.listglobally.com)

Ideas taken from lots of other great libraries, including ROXML, Happymapper, Sax Machine, and of course very reliant on Nokogiri.
