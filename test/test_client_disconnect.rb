require File.expand_path 'test_helper', File.dirname(__FILE__)
require 'sinatra/rocketio/linda/client'

class TestClientDisconnect < MiniTest::Test

  def test_client_disconnect
    ts_name = "ts_#{Time.now.to_i}_#{Time.now.usec}"
    client1 = Sinatra::RocketIO::Linda::Client.new App.url
    _tuple1 = nil
    _tuple2 = nil
    _tuple3 = nil
    _tuple4 = nil
    client1.io.on :connect do
      client2 = Sinatra::RocketIO::Linda::Client.new App.url
      client2.io.on :connect do
        ts1 = client1.tuplespace[ts_name]
        ts2 = client2.tuplespace[ts_name]
        ts1.read [1,2] do |tuple, info|
          _tuple1 = tuple
        end
        ts1.take [1,2] do |tuple, info|
          _tuple2 = tuple
        end
        ts1.watch [1,2] do |tuple, info|
          _tuple3 = tuple
        end
        ts2.take [1,2] do |tuple, info|
          _tuple4 = tuple
        end
        client1.io.close
        sleep 3
        ts2.write [1,2,3]
        ts2.write [1,2,3,4]
      end
    end
    50.times do
      sleep 0.1
      break if _tuple4
    end
    assert_equal _tuple1, nil
    assert_equal _tuple2, nil
    assert_equal _tuple3, nil
    assert_equal _tuple4, [1,2,3]
  end

end
