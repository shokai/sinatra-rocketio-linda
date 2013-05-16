require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/base'
$stdout.sync = true
$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'sinatra/rocketio'
require 'sinatra/rocketio/linda'
require File.dirname(__FILE__)+'/main'

set :websocketio, :port => ENV['WS_PORT'].to_i

run TestApp
