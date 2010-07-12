# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/noratext/ydml_grammer_definition')

describe "Noratext::Parser" do

  it "should accept open-close" do
    element = Noratext::Parser::Element.new(:center, nil, nil)
    element.open_close
    element.accept?({ :type => :center, :tag => { :name => :center, :kind => :opentag }}).should be_true
  end

  it "should accept text" do
    element = Noratext::Parser::Element.new(:text, nil, nil)
    element.accepts :text
    element.accept?({ :type => :text })
  end

  it "should accept open-close" do
    elements = {}
    elements[:text] = Noratext::Parser::Element.new(:text, nil, elements)
    elements[:text].accepts :text
    elements[:text].parse_sequence do
      |s|
      a = s.shift
      { :data => a[:data] }
    end
    element = Noratext::Parser::Element.new(:center, nil, elements)
    element.open_close
    element.contains :text
    element.accept?({ :type => :center, :tag => { :name => :center, :kind => :opentag }}).should be_true
    a = element.process([{ :type => :tag, :tag => { :name => :center, :kind => :opentag }},
                       { :type => :text, :data => "foobar" },
                         { :type => :center, :tag => { :name => :center, :kind => :closetag}}])
    a.type.should == :center
    a.is_leaf?.should_not be_true
    a.children.size.should == 1
    a.children[0].type.should == :text
    a.children[0].is_leaf?.should be_true
    a.children[0][:data].should == "foobar"
  end
  
end

describe Noratext::Parser do
  it "should parse valid test" do
    seq = [ { :type => :text, :data=>'これが中身', :line => 1} ]
    result = Noratext::Parser[:ydml].parse(seq)
    result.type.should == :document
    result.is_leaf?.should_not be_true
    result.children.size.should == 1
    result.children[0].is_leaf?.should_not be_true
    result.children[0].type.should == :paragraph

  end
  
end

