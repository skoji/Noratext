module Noratext
  class Processor
    class Element
      attr_accessor :result, :name
      def initialize(name, elements)
        @elements = elements
        @name = name
        @before = lambda {""}
        @proc = lambda {""}
        @after = lambda {""}
      end

      def before(&block)
        @before = block
      end

      def proc(&block)
        @proc = block
      end
      
      def after(&block)
        @after = block
      end

      def process(elem)
        @result = ""
        @result << @before.call(elem)
        @result << @proc.call(elem)
        @result << @after.call(elem)
      end
    end

    class OpenCloseElement < Element
      def initialize(name, elements)
        super(name, elements)

        @before = lambda {
          @open
        }
        
        @after = lambda {
          @close 
        }
        
        @proc = lambda {
          |elem|
          result = ""
          elem.children.each {
            |child|
            result << @elements[child.type].process(child)
          }
          result 
        }
      end
      def open (v)
        @open = v
      end

      def close (v)
        @close = v
      end
    end
    
    def element(name, &block)
      @elements[name] = Element.new(name, @elements)
      @elements[name].instance_eval(&block)
      @elements[name]
    end

    def openclose_element(name, &block)
      @elements[name] = OpenCloseElement.new(name, @elements)
      @elements[name].instance_eval(&block)
      @elements[name]
    end      

    def initialize
      @elements = {}
    end

    def process(parsedData)
      @elements[parsedData.type].process(parsedData)
    end
    
  end
end
