require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require File.expand_path 'app', File.dirname(__FILE__)
$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
