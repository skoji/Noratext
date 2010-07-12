module Noratext
  @parsers = {}
  class Parser


    def self.define(name, style = :xml_style, &block)
      parser = Perser.new
      @parsers[name] = parser
      parser.instance_eval(block)
    end

    def element(name, &block)
      element = Element.new(name)
      @elements[name] = element
      element.instance_eval(block)
    end

    def initialize
      @elements = {}
    end

    
  end
end
