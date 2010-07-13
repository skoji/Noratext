module Noratext
  class Parser
    @instances_block = {}
    def self.define(name, style = :xml_style, &block)
      parser = Parser.new
      @instances_block[name] = block
      parser.instance_eval(&block) # for check only
    end

    def self.generate(name)
      parser = Parser.new
      parser.instance_eval(&@instances_block[name])
      parser
    end

    def element(name, &block)
      element = Element.new(name, method(:logger), @elements)
      @start_element = element if @elements.size == 0
      @elements[name] = element
      element.instance_eval(&block)
    end

    def initialize
      @elements = {}
      @log = []
    end

    def parse(sequence)
      result = @start_element.process(sequence)
      logger sequence[0][:line], "unexpected #{sequence[0][:data]}" if (sequence.size > 0)
      result
    end

    def logger(lineno, log)
      @log << { :lineno => lineno, :log => log}
    end

    def log
      @log.sort_by { |entry| entry[:lineno] }.map { |entry| "#{entry[:lineno]}: #{entry[:log]}" }
    end
    
  end
end
