io = Sinatra::RocketIO
linda = Sinatra::RocketIO::Linda

io.on :connect do |client|
  puts "new client connect <#{client}>"
end

io.on :disconnect do |client|
  puts "bye <#{client}>"
end

linda.on :error do |err|
  STDERR.puts err
end


get '/' do
  haml :index
end

get '/worker' do
  haml :worker
end

get '/client' do
  haml :client
end
