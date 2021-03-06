module Noratext
  class Parser

    module Contains
      def element_to_parse
        @element_to_parse ||= @contains.map { |element_name| @elements[element_name] }
      end
      
      def process(sequence, parent)
        preprocess(sequence)
        children = []
        while (sequence.size > 0 && elem = process_one_element(sequence, parent))
          children << elem
        end
        postprocess(sequence)
        ParsedData.new(@name, parent, children)
      end
    end

    module IsOneof
      def element_to_parse
        @element_to_parse ||= @is_oneof.map { |element_name| @elements[element_name] }
      end

      def process(sequence, parent)
        if sequence.size > 0 && elem = process_one_element(sequence, parent)
          elem
        else
          nil
        end
      end
    end

    module OpenClose

      def accept?(token)
        is_opentag(token)
      end

      def preprocess(sequence)
        @opentag = sequence.shift[:tag]
      end

      def is_end_of_element(token)
        is_closetag(token)
      end
      
      def postprocess(sequence)
        return if sequence.size == 0

        if is_closetag(sequence[0])
          sequence.shift
          return
        end

        log @opentag[:line], "#{@name} is not closed}"
      end
    end

    module ParseToken
      def process(sequence, parent)
        return ParsedData.new(@name, parent).set_attributes(@parse_token_proc.call(sequence.shift))
      end
    end

    module ParseSequence
      def process(sequence, parent)
        return ParsedData.new(@name, parent).set_attributes(@parse_sequence_proc.call(sequence))
      end
    end
    
    class Element
      def accept?(token)
        if (@accept_type)
          return token[:type] == @accept_type
        else
          element_to_parse.each {
            |element|
            return true if (element.accept?(token)) 
          }
          return false
        end
      end

      def is_closetag(token)
        token[:type] == @name &&
          token[:tag][:kind] == :closetag
      end

      def is_opentag(token)
        token[:type] == @name &&
          token[:tag][:kind] == :opentag
      end
      
      def initialize(name, logger, elements)
        @name = name
        @logger = logger
        @elements = elements
      end

      def preprocess(sequence)
      end

      def postprocess(sequence)
      end

      def is_end_of_element(token)
        false
      end
      
      def process_one_element(sequence, parent)

        while (sequence.size > 0 && sequence[0][:kind] == :closetag)
          return nil if (is_end_of_element(sequence[0]))
          log sequence[0][:line],"no opentag for #{sequence[0][:type]}"
          sequence.shift
        end
        return nil if (sequence.size == 0) 

        element_to_parse.each {
          |element|
          return element.process(sequence, parent) if element.accept?(sequence[0])
        }
        nil
      end

      def contains(*array)
        raise 'already is_oneof are defined' if !@is_oneof.nil?
        @contains = array
        extend Contains
      end
      
      def is_oneof(*array)
        raise 'already contains are defined' if !@contains.nil?
        @is_oneof = array
        extend IsOneof
      end
      
      def open_close 
        extend OpenClose
      end

      def accepts(type)
        @accept_type = type
      end

      def parse_token(&block)
        raise 'already defined as parse sequence type' if !@parse_sequence_proc.nil?
        @parse_token_proc = block
        @accept_type ||= @name
        extend ParseToken
      end

      def parse_sequence(&block)
        raise 'already defined as parse token type' if !@parse_token_proc.nil?
        @parse_sequence_proc = block
        @accept_type ||= @name
        extend ParseSequence
      end

      def log(lineno, log)
        @logger.call(lineno, log) if !@logger.nil?
      end
    end

    class ParsedData
      include Enumerable
      attr_accessor :type, :children, :parent

      def initialize(type, parent, children = [])
        @children = children
        @parent = parent
        @type = type
        @attributes = {}
      end

      def is_leaf?
        @children.size == 0
      end

      def set_attributes(value)
        @attributes.merge!(value)
        value.each {
          |k,v|
          (class << self; self; end).instance_eval{define_method(k){v}}
        }
        self
      end

      def each (&block)
        yield self
        @children.each {
          |child|
          child.each (&block)
        }
        self
      end
      
      # can't search inside tag like 'ruby'.
      def search_regex(regex)
        select { |elem| elem.type == :text && regex =~ elem.data }
      end

    end
  end
end
