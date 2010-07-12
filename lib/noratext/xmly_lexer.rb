# -*- coding: utf-8 -*-
module Noratext
  class XmlyLexer < Lexer

    def initialize
      super
    end

    def tag_class
      return XmlyTag
    end

    def closetag_for(tag)
      "</#{tag.to_s}>"
    end

    class XmlyTag < Lexer::Tag
      def self.default_attribute_parser
        lambda {
          |s|
          { :kind => /^<\// =~ s ? :closetag : :opentag }
        }
      end

      def initialize(name)
        super
        @attribute_parsers << self.class.default_attribute_parser
      end
      
      def matcher(s)
        tagpattern = "<#{@match_pattern}.*?>"
        tagpattern = "</?#{@match_pattern}.*?>" if @with_close
        /#{tagpattern}/.match s
      end
    end

  end
end
