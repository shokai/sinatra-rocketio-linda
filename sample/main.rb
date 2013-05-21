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

linda.on :write do |tuple, client|
  puts "write #{tuple.tuple} in <#{tuple.space}> by <#{client}>"
end

linda.on :read do |tuple, client|
  puts "read #{tuple.tuple} in <#{tuple.space}> by <#{client}>"
end

linda.on :take do |tuple, client|
  puts "take #{tuple.tuple} in <#{tuple.space}> by <#{client}>"
end

linda.on :watch do |tuple, client|
  puts "watch #{tuple.tuple} in <#{tuple.space}> by <#{client}>"
end
