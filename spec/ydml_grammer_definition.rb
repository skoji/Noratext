Noratext::Parser.define :ydml do
  element :document do
    contains :block
  end

  element :block do
    is_oneof :paragraph, :center, :left, :right, :quote, :hasen
  end

  element :paragraph do
    contains :text, :large, :small, :bold, :image, :sonomama, :ruby 
  end
  
  element :center do
    open_close 
    contains :paragraph
  end

  element :left do
    open_close 
    contains :paragraph 
  end

  element :right do
    open_close 
    contains :paragraph 
  end

  element :quote do
    open_close
    contains :paragraph
  end

  element :hasen do
    parse_token do
      |token|
      {}
    end
  end

  element :text do
    accepts :text
    parse_sequence do
      |sequence|
      data = ""
      while (sequence.size > 0 &&
             sequence[0][:type] == :text)
        data << sequence.shift[:data]
      end
      { :data => data }
    end
  end

  element :large do
    open_close
    contains  :paragraph 
  end

  element :small do
    open_close
    contains  :paragraph 
  end

  element :bold do
    open_close
    contains :paragraph
  end

  element :image do
    parse_token do
      |token|
      { :imagepath => token[:imagepath], :size => token[:size] }
    end
  end

  element :sonomama do
    open_close
    contains :text
  end

  element :ruby do
    parse_sequence do
      |sequence|
      sequence.shift
      /(.+)\/(.+)/ =~ sequence[0][:data]
      raise "#{sequence[0][:data]} is invalid inside ruby tag." if $1.nil?
      sequence.shift
      raise "rubytag is not closed" if !is_closetag(sequence[0])
      sequence.shift
      { :body => $1, :ruby => $2 }
    end
    
  end
  
end
