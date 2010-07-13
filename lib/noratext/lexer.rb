# -*- coding: utf-8 -*-
module Noratext
  class Lexer
    @instances_block = {}
    def self.define(name, style = :xml_style, &block)
      case style
      when :xml_style
        lexer = XmlyLexer.new
      end
      @instances_block[name] = { :lexer_class => lexer.class, :block => block }
      lexer.instance_eval(&block) # for check only
    end

    def self.generate(name)
      lexer = @instances_block[name][:lexer_class].new
      lexer.instance_eval(&@instances_block[name][:block])
      lexer
    end

    def initialize
      @tags = {}
    end
    def process(io)
      result = []
      while line = io.gets
        result = result + read_line(line, io.lineno)
      end
      result
    end

    def symbols(*symbols)
      symbols.each {
        |symbol|
        @tags[symbol] = tag_class.new(symbol)
      }
    end

    def symbol(symbol, &block)
      @tags[symbol] = tag_class.new(symbol)
      @tags[symbol].instance_eval(&block)
    end

    def match_pattern(tag, pattern)
      @tags[tag].match_pattern pattern
    end

    def without_close(*tags)
      tags.each {
        |tag|
        @tags[tag].without_close
      }
    end
    
    def add_parser(tag, &block)
      @tags[tag].attribute_parsers << block
    end

    def rawtext_till_close(tag, closetag = nil)
      closetag ||= closetag_for(tag)
      @tags[tag].rawtext_till_close closetag
    end

    def read_line(s, line_no)
      return [] if s == ""
      result = []

      if @rawtext_tag
        matched = /#{@rawtext_close_tag}/.match(s)
        if matched.nil?
          return [{ :type => :text, :data => s, :line => line_no }]
        else
          result << { :type => :text, :data => matched.pre_match, :line => line_no }
          result << {
            :type => @rawtext_tag.name,
            :data => matched[0],
            :line => line_no,
            :tag => { :name => @rawtext_tag.name }.merge(@rawtext_tag.parse_attribute(matched[0])) }

          @rawtext_tag = nil
          @rawtext_close_tag = nil
          return result + read_line(matched.post_match, line_no)
        end
      end

      t = factory(s)
      if (t.nil?)
        return [{ :type => :text, :data => s, :line => line_no }]
      else
        result << { :type => :text, :data => t[:pre], :line => line_no } if t[:pre] != ""
        result << { :type => t[:tag][:name], :data => t[:data], :line => line_no, :tag => t[:tag] }
        result + read_line(t[:rest], line_no)
      end
    end
    
    def factory(s)
      matched = @tags.map {
        |name, tag|
        { :tag => tag, :match => tag.matcher(s) } 
      }.select { |m| !m[:match].nil? }.sort_by { |m| m[:match].begin(0) }

      return nil if matched.size == 0
      m = matched[0][:match]
      tag = matched[0][:tag]

      @rawtext_tag = tag if @rawtext_close_tag = tag.rawtext_till_close_tag
      { :pre => m.pre_match,
        :rest => m.post_match,
        :data => m[0],
        :tag => { :name => tag.name }.merge(tag.parse_attribute(m[0]))  }
    end
    
    class Tag
      attr_accessor :name, :attribute_parsers, :rawtext_till_close_tag

      def initialize(name)
        @name = name
        @match_pattern = name.to_s
        @attribute_parsers = []
        @with_close = true
        @rawtext_till_close_tag = nil
      end

      def without_close
        @with_close = false
      end

      def rawtext_till_close(tag = nil)
        tag ||= closetag_for(@name)
        @rawtext_till_close_tag = tag
      end

      def add_parser(&block)
        @attribute_parsers << block
      end

      def match_pattern(pattern)
        @match_pattern = pattern
      end
      
      def parse_attribute(s)
        result = {}
        @attribute_parsers.each {
          |parser|
          result.merge!(parser.call(s))
        }
        result
      end

    end
  end
end

