require File.expand_path 'test_helper', File.dirname(__FILE__)
require 'sinatra-rocketio-linda/tuple'
require 'sinatra-rocketio-linda/tuplespace'

class TestTupleSpace < MiniTest::Test

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
    assert_equal @space.read(:a => 1, :c => 999).data, {:a => 1, :b => 2, :c => 999}
    assert_equal @space.read(:a => 1).data, {:a => 1, :b => 2, :c => 3}
  end

  def test_write_read_callback
    assert_equal @space.size, 0
    _tuple1 = nil
    @space.read [1,2] do |tuple|
      _tuple1 = tuple
    end
    _tuple2 = nil
    @space.read [1,"a"] do |tuple|
      _tuple2 = tuple
    end
    _tuple3 = nil
    @space.read [1,2,3] do |tuple|
      _tuple3 = tuple
    end
    @space.write [1,2,3]
    assert_equal _tuple1.data, [1,2,3]
    assert_equal _tuple2, nil
    assert_equal _tuple3.data, [1,2,3]
    assert_equal @space.read([1]).data, [1,2,3]
    assert_equal @space.size, 1
    @space.write [1,2,4]
    assert_equal _tuple1.data, [1,2,3]
    assert_equal @space.size, 2
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

  def test_take_callback
    assert_equal @space.size, 0
    _tuple1 = nil
    @space.take [1,2] do |tuple|
      _tuple1 = tuple
    end
    _tuple2 = nil
    @space.take [1,"a"] do |tuple|
      _tuple2 = tuple
    end
    _tuple3 = nil
    @space.read [1,2,3] do |tuple|
      _tuple3 = tuple
    end
    _tuple4 = nil
    @space.take [1,2,3] do |tuple|
      _tuple4 = tuple
    end
    1.upto(3) do |i|
      @space.write [1,2,3,"a"*i]
    end
    assert_equal @space.size, 1
    assert_equal _tuple1.data, [1,2,3,"a"]
    assert_equal _tuple2, nil
    assert_equal _tuple3.data, [1,2,3,"aa"]
    assert_equal _tuple4.data, [1,2,3,"aa"]
    assert_equal @space.take([1]).data, [1,2,3,"aaa"]
    assert_equal @space.size, 0
  end

  def test_watch
    assert_equal @space.size, 0
    _tuple1 = nil
    @space.take [1] do |tuple|
      _tuple1 = tuple
    end
    results = []
    @space.watch [1,2] do |tuple|
      results << tuple
    end
    @space.write [1,2,3]
    @space.write [1,2,"aa"]
    @space.write [1,"a",3]
    assert_equal _tuple1.data, [1,2,3]
    assert_equal @space.size, 2
    assert_equal results.size, 2
    assert_equal results[0].data, [1,2,3]
    assert_equal results[1].data, [1,2,"aa"]
  end

  def test_tuple_expire
    @space.write [1,2,999], :expire => false
    @space.write [1,2,3], :expire => 3
    @space.write [1,2,"a","b"], :expire => 2
    assert_equal @space.size, 3
    sleep 2
    @space.check_expire
    assert_equal @space.size, 2
    assert_equal @space.take([1,2]).data, [1,2,3]
    assert_equal @space.size, 1
    sleep 1
    assert_equal @space.take([1,2]).data, [1,2,999]
    assert_equal @space.size, 0
  end

end
