# coding: utf-8

HELP = {
  'basic' => [%[I didn't understand you.], %[Second of the first.], %[third of one.]],
  'not basic' => [%[not basic stuff], %[okay, so maybe not as basic]]
}

def levelup? u
  u = user(u)
  if u[:xp].to_i > ((u[:lvl].to_i + 1) * CONF["webconfig"]['lvlup'].to_i).to_i
    return true
  else
    return false
  end
end

on(/help (.*)/) do |msg|
  topic = $1
  puts "HELP"
  if $1
  if HELP.has_key? $1
    {
      message: "I know this about #{$1}",                                                                                                                                                 
      content: '<p class="manpage">' + HELP[$1].join('</p><p class="manpage">') + '</p>'
    }
  else
    {
      message: "I don't know about that...",
      content: %[<p class="manhead">I Do know about:</p><ul><li class="manhead">] + HELP.keys.join('</li><li class="manhead">') + '</li></ul>',
    }
  end
else
 {                                                                                                                                                                                                                   
   message: "Let me help",
   content: HELP.map { |e| %[<div class="help"><p class="manhead">#{e[0]}</p><p class="manpage">#{e[1].join('</p><p class="manpage">')}</p></div>] }
 }
  end
end
on("user") do |h|
  if h[:user]
    u = user(h[:user])
    if u[:xp] == nil
      CONF['webconfig']['stats'].each_pair { |k,v| u[k] = v[1] }
      [:xp, :hp, :lvl].each {|e| u[e] = 0 }
    end
  end
end
