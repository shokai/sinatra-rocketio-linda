$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'rubygems'
require 'bundler/setup'
require 'sinatra/rocketio/linda/client'

linda = Sinatra::RocketIO::Linda::Client.new('http://localhost:5000').connect

linda.read :calc do |query|
  puts query
  linda.write :calc_result, eval(query)
end

linda.on :connect do |io|
  puts "connect #{io.session}"
end

linda.on :disconnect do |io|
  puts "disconnect #{io.session}"
end

loop do
end
