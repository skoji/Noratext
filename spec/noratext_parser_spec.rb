# -*- coding: utf-8 -*-
$KCODE='u'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/ydml_grammer_definition')

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
    a = element.process([{ :type => :center, :tag => { :name => :center, :kind => :opentag }},
                       { :type => :text, :data => "foobar" },
                         { :type => :center, :tag => { :name => :center, :kind => :closetag}}], nil)
    a.type.should == :center
    a.is_leaf?.should_not be_true
    a.children.size.should == 1
    a.children[0].type.should == :text
    a.children[0].is_leaf?.should be_true
    a.children[0].data.should == "foobar"
  end
  
end

describe Noratext::Parser do
  it "should parse valid test" do
    seq = [ { :type => :text, :data=>'これが中身', :line => 1} ]
    result = Noratext::Parser.generate(:ydml).parse(seq)
    result.type.should == :document
    result.is_leaf?.should_not be_true
    result.children.size.should == 1
    result.children[0].is_leaf?.should_not be_true
    result.children[0].type.should == :paragraph
    result.children[0].children.size.should == 1
    result.children[0].children[0].type.should == :text
    result.children[0].children[0].data.should == 'これが中身'
  end

  it "should parse nested data" do
    seq = [ { :type => :center, :tag => { :name => :center, :kind => :opentag}},
            { :type => :text, :data=>'センタリング', :line => 1},
            { :type => :center, :tag => { :name => :center, :kind => :closetag}},
            { :type => :ruby, :tag => { :name => :ruby, :kind => :opentag }},
            { :type => :text, :data => '蜻蛉/とんぼ', :line => 2 },
            { :type => :ruby,:tag => { :name => :ruby, :kind => :closetag }}
          ]

    parser = Noratext::Parser.generate(:ydml)
    result = parser.parse(seq)
    result.type.should == :document
    result.log.size.should == 0
    result.children.size.should == 2
    result.children[0].is_leaf?.should_not be_true
    result.children[0].type.should == :center
    result.children[0].children.size.should == 1
    result.children[0].children[0].type.should == :paragraph
    result.children[0].children[0].children[0].data.should == 'センタリング'
    result.children[1].type.should == :paragraph
    result.children[1].children.size.should == 1
    result.children[1].children[0].type.should == :ruby
    result.children[1].children[0].ruby.should == 'とんぼ'
    result.children[1].children[0].body.should == '蜻蛉'
  end
end

describe Noratext::Parser::ParsedData do

  it "should search data" do
    seq = [ { :type => :center, :tag => { :name => :center, :kind => :opentag}},
            { :type => :text, :data=>'センタリング', :line => 1},
            { :type => :center, :tag => { :name => :center, :kind => :closetag}},
            { :type => :ruby, :tag => { :name => :ruby, :kind => :opentag }},
            { :type => :text, :data => '蜻蛉/とんぼ', :line => 2 },
            { :type => :ruby,:tag => { :name => :ruby, :kind => :closetag }},
            { :type => :text, :data=>'蜻蛉か', :line => 1},
          ]

    parser = Noratext::Parser.generate(:ydml)
    result = parser.parse(seq)
    
    a = result.select { |elem| elem.type == :text && elem.data == 'センタリング' }
    a.size.should == 1
    a[0].type.should == :text
    a[0].data.should == 'センタリング'

  end
end

