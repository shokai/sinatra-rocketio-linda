class TestApp < Sinatra::Base
  register Sinatra::RocketIO
  io = Sinatra::RocketIO
  register Sinatra::RocketIO::Linda
  linda = Sinatra::RocketIO::Linda

  get '/' do
    "sinatra-rocketio-linda v#{Sinatra::RocketIO::Linda::VERSION}"
  end

  io.on :connect do |client|
    puts "new client <session:#{client.session}> <type:#{client.type}>"
  end

  io.on :disconnect do |client|
    puts "disconnect client <session:#{client.session}> <type:#{client.type}>"
  end

  io.on :check_expire do |data, client|
    puts "check_expire"
    linda.check_expire
  end

  io.on :* do |event, data, client|
    next unless event.to_s =~ /linda/
    puts "#{event} - #{data} from #{client}"
  end
end
