# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Noratext::Lexer" do
  before do
    Noratext::Lexer.define :test do
      symbols :center, :left, :right, :quote
      rawtext_till_close :quote

      symbol :paragraph do
        match_pattern 'p'
        without_close
      end

      symbol :image do
        match_pattern 'img'
        without_close
        add_parser do
          |s|
          /src="(.*?)"/ =~ s
          path = $1
          /scale="(.*?)"/ =~ s
          scale = $1
          { :path => path, :scale => scale }
        end
      end
    end
  end

  it "should parse tag correctly" do
    lexer = Noratext::Lexer.generate(:test)
    opentag = lexer.factory('<center>')
    closetag = lexer.factory('</center>')

    opentag[:tag][:name].should == :center
    opentag[:tag][:kind].should == :opentag

    closetag[:tag][:name].should == :center
    closetag[:tag][:kind].should == :closetag
  end

  it "should create parse path" do
    lexer = Noratext::Lexer.generate(:test)
    tag = lexer.factory('<img src="../img/path.jpg">')
    tag[:tag][:name].should == :image
    tag[:tag][:kind].should == :opentag
    tag[:tag][:path].should == '../img/path.jpg'
    tag[:tag][:scale].should be_nil
  end

  it "should create parse path" do
    lexer = Noratext::Lexer.generate(:test)
    tag = lexer.factory('<img src="../img/path.jpg" scale="90%">')
    tag[:tag][:name].should == :image
    tag[:tag][:kind].should == :opentag
    tag[:tag][:path].should == '../img/path.jpg'
    tag[:tag][:scale].should == '90%'
  end

  it "should parse rawtext tag" do
    lexer = Noratext::Lexer.generate(:test)
    text = "<quote>この部分は、<center>とかはいっていても、そのまま見えるはず。
<bold>改行</bold>しても、扱えるはず。</quote>このへんは、タグを<center>読む。"
    io = StringIO.new(text)

    processed = lexer.process(io)
    processed.size.should == 7
    processed[0][:type].should == :quote
    processed[1][:type].should == :text
    processed[1][:data].should == "この部分は、<center>とかはいっていても、そのまま見えるはず。\n"
    processed[2][:type].should == :text
    processed[2][:data].should == '<bold>改行</bold>しても、扱えるはず。'
    processed[3][:type].should == :quote
    processed[4][:type].should == :text
    processed[4][:data].should == 'このへんは、タグを'
    processed[5][:type].should == :center
    processed[6][:type].should == :text
    processed[6][:data].should == '読む。'
  end

  
end
