io = Sinatra::RocketIO
linda = Sinatra::RocketIO::Linda

linda.read :foo do |data|
  puts "foo!! #{data}"
end

io.on :connect do |client|
  puts "new client connect <#{client}>"
end

io.on :disconnect do |client|
  puts "bye <#{client}>"
end


get '/' do
  haml :index
end
