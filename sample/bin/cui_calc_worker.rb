$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'rubygems'
require 'bundler/setup'
require 'sinatra/rocketio/linda/client'

linda = Sinatra::RocketIO::Linda::Client.new 'http://localhost:5000'
ts = linda.tuplespace["calc"]

calc = lambda{
  ts.take ["calc_request"] do |tuple|
    query = tuple[1]
    result = eval(query)
    puts "calc: #{query} = #{result}"
    ts.write ["calc_result", result]
    calc.call
  end
}

linda.io.on :connect do
  puts "connect #{io.session}"
  calc.call
end

linda.io.on :disconnect do
  puts "disconnect #{io.session}"
end

linda.io.on :error do |err|
  STDERR.puts err
end

loop do
  sleep 1
end
