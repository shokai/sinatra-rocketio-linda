module Sinatra
  module RocketIO
    module Linda

      def self.tuplespaces
        @@spaces ||= Hash.new{|h,k| h[k] = TupleSpace.new }
      end

      def self.[](name)
        self.tuplespaces[name]
      end

    end
  end
end

EventEmitter.apply Sinatra::RocketIO::Linda

Sinatra::RocketIO.on :__linda_write do |data, client|
  space, tuple, opts = data
  space = "__default__" if !space or !space.kind_of? String or space.empty?
  unless [Hash, Array].include? tuple.class
    Sinatra::RocketIO::Linda.emit :error, "received Tuple is not Hash or Array at :__linda_write"
    next
  end
  opts = {} unless opts.kind_of? Hash
  Sinatra::RocketIO::Linda[space].write tuple, opts
end

Sinatra::RocketIO.on :__linda_read do |data, client|
  space, tuple, callback = data
  space = "__default__" if !space or !space.kind_of? String or space.empty?
  unless [Hash, Array].include? tuple.class
    Sinatra::RocketIO::Linda.emit :error, "received Tuple is not Hash or Array at :__linda_read"
    next
  end
  if !callback or !callback.kind_of? String or callback.empty?
    Sinatra::RocketIO::Linda.emit :error, "received Callback ID is not valid at :__linda_read"
    next
  end
  Sinatra::RocketIO::Linda[space].read tuple do |tuple|
    Sinatra::RocketIO.push "__linda_read_callback_#{callback}", tuple.data, :to => client.session
  end
end

Sinatra::RocketIO.on :__linda_take do |data, client|
  space, tuple, callback = data
  space = "__default__" if !space or !space.kind_of? String or space.empty?
  unless [Hash, Array].include? tuple.class
    Sinatra::RocketIO::Linda.emit :error, "received Tuple is not Hash or Array at :__linda_take"
    next
  end
  if !callback or !callback.kind_of? String or callback.empty?
    Sinatra::RocketIO::Linda.emit :error, "received Callback ID is not valid at :__linda_take"
    next
  end
  Sinatra::RocketIO::Linda[space].take tuple do |tuple|
    Sinatra::RocketIO.push "__linda_take_callback_#{callback}", tuple.data, :to => client.session
  end
end
