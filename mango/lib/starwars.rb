require 'erb'
module StarWars
  CSS = [

%[#target{
    position:absolute;
    top:-<%= @padding %>px;
    bottom:0;
    left:0;
    right:0;
    overflow:hidden;
    font-size:30px;
    text-align:center;
    font-family:sans-serif;
}],
%[#target>div{
    padding-top:<%= (@padding * 1.1).to_i %>px;
    animation:autoscroll 1000s linear;
}],
%[html:after{
    content:'';
    position:absolute;
    top:0;
    bottom:0;
    left:0;
    right:0;
    background:linear-gradient(top,rgba(0,0,0,1),rgba(0,0,0,0) 100%);
    background:linear-gradient(to bottom,rgba(0,0,0,1),rgba(0,0,0,0) 100%);
    pointer-events:none;
}],

%[body{
    
    position:absolute;
    top:0;
    bottom:0;
    left:0;
    right:0;
    transform-origin:50% 100%;
    transform:perspective(300px) rotateX(20deg);
}],
%[html{
    color:yellow;
    background:black;
}],
%[@keyframes autoscroll{
    to{
        margin-top:-<%= @padding * 15 %>px;
    }    
}]]
  def self.padding p
    @padding = p
  end
  def self.style
    %[<style>#{ERB.new(CSS.join('')).result(binding)}</style>]
  end
  def self.scroll t, h={}
    if h[:padding]
      @padding = h[:padding]
    end
    %[#{StarWars.style}<div id="target"><div>#{t}</div></div>]
  end
end
