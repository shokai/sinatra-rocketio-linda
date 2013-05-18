require File.expand_path 'test_helper', File.dirname(__FILE__)
require 'sinatra-rocketio-linda/tuple'
require 'linda/test/tuple'

class TestTuple < MiniTest::Test
  include Linda::Test::Tuple

  def target_tuple
    Sinatra::RocketIO::Linda::Tuple
  end
end
