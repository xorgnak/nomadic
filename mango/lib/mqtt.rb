require 'mqtt'

def mqtt_ping_loop del
Process.detach(fork {
                 loop do
                   mqtt_publish("ping", Time.now.to_i)
                   sleep del
                 end
               })
end

def mqtt_publish ch, m
  MQTT::Client.connect('localhost') do |c|                                                                                   
    c.publish(ch, m)                                                                                        
  end
end

def mqtt_subscribe(ch, &b)
Process.detach(fork {
                 MQTT::Client.connect('localhost') { |client|
                   client.get(ch) { |topic,message|
                     b.call(topic, message)
                   }
                 }
               }
              )
end
               
