HELP = {
  'basic' => [%[I didn't understand you.], %[Second of the first.], %[third of one.]],
  'not basic' => [%[not basic stuff], %[okay, so maybe not as basic.]]
}


on(/help/) do |msg|
  puts "HELP"
  {
    message: "Let me help",
    content: HELP.map { |e| %[<div class="help"><p class="manhead">#{e[0]}</p><p class="manpage">#{e[1].join('</p><p class="manpage">')}</p></div>] },
    state: {
      heart: 0,
      rocket: 0,
      medal: 0
    }
  }
end
on(/help (.*)/) do |msg|
  topic = $1
  if HELP.has_key? topic
    {
      message: "I know this about #{topic}",                                                                                                                                                 
      content: '<p class="manpage">' + HELP[topic].join('</p><p class="manpage">') + '</p>',                                                                                          
      state: {                          
        heart: 0,                         
        rocket: 0,                           
        medal: 0
      }                                                                                                                                                                                                              
    }
  else
    {
      message: "I don't know about that...",
      content: %[<p class="manhead">I Do know about:</p><ul><li class="manhead">] + HELP.keys.join('</li><li class="manhead">') + '</li></ul>',
      state: {
        heart: 0,
        rocket: 0,
        medal: 0
      }
    }
  end
end
on(/\d{10}/) do |msg|
  puts "AUTH> #{msg}"
  Redis::Set.new("users") << msg
  {
    message: %[<h3>Welcome, #{msg}!],
    content: %[You're just a number here soldier!  Listen to your driver.  They'll explain how to use your inter-dimensional zapper and how to go home safe.  Good luck!</h3>],
    state: {
      heart: Redis::HashKey.new("user:#{msg}")[:heart],
      rocket: Redis::HashKey.new("user:#{msg}")[:rocket],
      medal: Redis::HashKey.new("user:#{msg}")[:medal]
    }
  }
end
