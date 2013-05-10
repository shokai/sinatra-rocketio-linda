require File.expand_path 'test_helper', File.dirname(__FILE__)
require 'sinatra-rocketio-linda/tuple'

class TestTuple < MiniTest::Unit::TestCase
  def test_match_array
    tuple = Sinatra::RocketIO::Linda::Tuple.new [1,2,3]
    assert tuple.match? Sinatra::RocketIO::Linda::Tuple.new [1,2,3]
    assert tuple.match? Sinatra::RocketIO::Linda::Tuple.new [1,2,3,4]
    assert !tuple.match?(Sinatra::RocketIO::Linda::Tuple.new [1,2])
    assert !tuple.match?(Sinatra::RocketIO::Linda::Tuple.new [1,"a",3])
    assert !tuple.match?(Sinatra::RocketIO::Linda::Tuple.new :a => 1, :b => 2)
    tuple = Sinatra::RocketIO::Linda::Tuple.new ["a","b","c"]
    assert tuple.match? Sinatra::RocketIO::Linda::Tuple.new ["a","b","c"]
    assert tuple.match? Sinatra::RocketIO::Linda::Tuple.new ["a","b","c","d","efg",123,"h"]
    assert !tuple.match?(Sinatra::RocketIO::Linda::Tuple.new ["a","b"])
    assert !tuple.match?(Sinatra::RocketIO::Linda::Tuple.new ["a","b",789])
    assert !tuple.match?(Sinatra::RocketIO::Linda::Tuple.new :foo => 1, :bar => 2)
  end
end
