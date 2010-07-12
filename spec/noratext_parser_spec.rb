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
    a[:name].should == :center
  end
  
  it "should parse valid test" do
    seq = [ { :type => :text, :data=>'これが中身', :line => 1} ]
    p Noratext::Parser[:ydml].parse(seq)
  end
end
