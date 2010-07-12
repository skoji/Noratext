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
          /src="(.*)"/ =~ s
          path = $1
          /scale="(.*)"/ =~ s
          scale = $1
          { :path => path, :scale => scale }
        end
      end
    end
  end

  it "should parse tag correctly" do
    lexer = Noratext::Lexer[:test]
    opentag = lexer.factory('<center>')
    closetag = lexer.factory('</center>')

    opentag[:tag][:name].should == :center
    opentag[:tag][:kind].should == :opentag

    closetag[:tag][:name].should == :center
    closetag[:tag][:kind].should == :closetag
  end

  it "should create parse path" do
    lexer = Noratext::Lexer[:test]
    tag = lexer.factory('<img src="../img/path.jpg">')
    tag[:tag][:name].should == :image
    tag[:tag][:kind].should == :opentag
    tag[:tag][:path].should == '../img/path.jpg'
    tag[:tag][:scale].should be_nil
  end

  it "should create parse path" do
    lexer = Noratext::Lexer[:test]
    tag = lexer.factory('<img src="../img/path.jpg" scale="90%">')
    tag[:tag][:name].should == :image
    tag[:tag][:kind].should == :opentag
    tag[:tag][:path].should == '../img/path.jpg'
    tag[:tag][:scale].should == '90%'
  end

  
end
