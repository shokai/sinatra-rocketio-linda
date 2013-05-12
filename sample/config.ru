$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/rocketio'
require 'sinatra/reloader' if development?
require 'sinatra/rocketio/linda'
require File.expand_path 'main', File.dirname(__FILE__)

set :linda, :expire_check => 20

run Sinatra::Application
