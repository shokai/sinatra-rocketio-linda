require File.expand_path 'test_helper', File.dirname(__FILE__)
require 'sinatra-rocketio-linda/tuple'
require 'sinatra-rocketio-linda/tuplespace'
require 'linda/test/tuplespace'

class TestTupleSpace < MiniTest::Test
  include Linda::Test::TupleSpace

  def target_tuple
    Sinatra::RocketIO::Linda::Tuple
  end

  def target_tuplespace
    Sinatra::RocketIO::Linda::TupleSpace
  end
end
