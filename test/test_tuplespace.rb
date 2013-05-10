require File.expand_path 'test_helper', File.dirname(__FILE__)
require File.expand_path 'test_helper', File.dirname(__FILE__)
require 'sinatra-rocketio-linda/tuple'

class TestTupleSpace < MiniTest::Unit::TestCase
  def test_write_read
    space = Sinatra::RocketIO::Linda::TupleSpace.new
    assert_equal space.size, 0
    space.write Sinatra::RocketIO::Linda::Tuple.new [1,2,3]
    assert_equal space.size, 1
    assert_equal space.read([1,2]).data, [1,2,3]
    space.write :a => 1, :b => 2, :c => 999
    space.write :a => 1, :b => 2, :c => 3
    assert_equal space.size, 3
    assert_equal space.read(:a => 1, :c => 999).data, {:a => 1, :b => 2, :c => 999}
    assert_equal space.read(:a => 1).data, {:a => 1, :b => 2, :c => 3}
  end
end
