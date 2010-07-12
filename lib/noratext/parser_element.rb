module Noratext
  class Parser
    class Element
      def initialize(name)
        @name = name
      end
      def contains(*array)
        raise 'already is_oneof are defined' if !@is_oneof.nil?
        @contains = array
      end
      def is_oneof(*array)
        raise 'already contains are defined' if !@contains.nil?
        @is_oneof = array
      end
      def open_close
        
      end
      def accept_open
        
      end
      def parse_token(&block)
        @parse_token_proc = block
      end

      def parse_sequence(&block)
        @parse_sequence_proc = block
      end
      
    end
  end
end
