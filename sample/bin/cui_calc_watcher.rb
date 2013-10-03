$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'rubygems'
require 'bundler/setup'
require 'sinatra/rocketio/linda/client'

linda = Sinatra::RocketIO::Linda::Client.new 'http://localhost:5000'
ts = linda.tuplespace["calc"]

linda.io.on :connect do
  puts "connect #{io.session}"
  ts.watch [] do |tuple, info|
    puts "watch #{tuple} (from:#{info.from})"
  end
end

linda.io.on :disconnect do
  puts "disconnect #{io.session}"
end

linda.wait
