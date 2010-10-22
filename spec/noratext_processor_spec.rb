# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Hash
  def to_elem
    a = Object.new
    self.each {
      |k,v|
      (class << a; self; end).instance_eval{define_method(k){v}}
    }
    a
  end
end

describe "Noratext::Processor::Element" do
  it "should output proc" do
    processor = Noratext::Processor.new
    e = processor.element('test') do
      proc do
        |elem|
        elem.data.gsub("\n", "<br />\n")
      end
    end

    e.process({ :data => 'foo
bar'}.to_elem)

    e.result.should == "foo<br />\nbar"
  end

  it "should do correct open-close" do
    processor = Noratext::Processor.new

    e = processor.openclose_element :test do
      open "<open>"
      close"<close>"
    end

    processor.element :inner do
      proc do
        |elem|
        elem.data
      end
    end

    i = { :type => :test, :children => [ { :data => 'contents', :type => :inner }.to_elem ] }.to_elem
    processor.process(i).should == "<open>contents<close>"
  end

end
