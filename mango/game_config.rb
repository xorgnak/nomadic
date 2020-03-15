@mode = :solo
@die = 3
@hello = ""

game do |p|
  puts "POST> #{p}"
  p
end

logic do |u|
  if u[:medal].to_i <= 3                                                                                                                                                                                         
    u[:spec] = :black                                                                                                                                                                                            
  elsif u[:lvl].to_i <= 7 && u[:lvl].to_i > 3                                                                                                              
    u[:spec] = :red                                                                                                                                                                                              
  elsif u[:lvl].to_i <= 10 && u[:lvl].to_i > 7                                                                                                                               
    u[:spec] = :green                                                                                                                                                                                            
  else                                                                                                                                                                                                            
    u[:spec] = :gold                                                                                                                                                                                             
  end
  u
end

post do |p|
  puts "POST> #{p}"
  p
end

msg do |m, p|
  puts "MSG> #{m} #{p}"
  p
end
