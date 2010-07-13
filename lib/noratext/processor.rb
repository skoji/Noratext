module Noratext
  class Processor
    def element(name, &block)
      @processor[name] = block
    end

    def initialize
      @processors = {}
      @stack = []
    end

    def process(parsedData)
      @stack.push(parsedData)
      @processors[parsedData.type].call(parsedData)
      @stack.pop
    end
    
  end
end
