require File.expand_path 'test_helper', File.dirname(__FILE__)
require 'sinatra-rocketio-linda/tuple'

class TestTupleSpace < MiniTest::Unit::TestCase

  def setup
    @space = Sinatra::RocketIO::Linda::TupleSpace.new
  end

  def test_write_read
    assert_equal @space.size, 0
    @space.write Sinatra::RocketIO::Linda::Tuple.new [1,2,3]
    assert_equal @space.size, 1
    assert_equal @space.read([1,2]).data, [1,2,3]
    @space.write :a => 1, :b => 2, :c => 999
    @space.write :a => 1, :b => 2, :c => 3
    assert_equal @space.size, 3
    assert_equal @space.read(:a => 1, :c => 999).data, {:a => 1, :b => 2, :c => 999}
    assert_equal @space.read(:a => 1).data, {:a => 1, :b => 2, :c => 3}
  end

  def test_take
    assert_equal @space.size, 0
    1.upto(3) do |i|
      @space.write [1,2,3,"a"*i]
    end
    assert_equal @space.size, 3
    assert_equal @space.take([1,2,3]).data, [1,2,3,"aaa"]
    assert_equal @space.size, 2
    @space.write :a => 1, :b => 2, :c => 3
    assert_equal @space.size, 3
    assert_equal @space.take([1,3]), nil
    assert_equal @space.take(:a => 1, :b => 2, :c => 4), nil
    assert_equal @space.take([1,2,3]).data, [1,2,3,"aa"]
    assert_equal @space.size, 2
    assert_equal @space.take([1,2,3]).data, [1,2,3,"a"]
    assert_equal @space.size, 1
    assert_equal @space.take(:b => 2, :a => 1).data, {:a => 1, :b => 2, :c => 3}
    assert_equal @space.size, 0
  end

  def test_tuple_expire
    @space.write [1,2,3], :expire => 3
    @space.write [1,2,"a","b"], :expire => 2
    assert_equal @space.size, 2
    sleep 2
    @space.check_expire
    assert_equal @space.size, 1
    assert_equal @space.take([1,2]).data, [1,2,3]
    assert_equal @space.size, 0
  end

end
