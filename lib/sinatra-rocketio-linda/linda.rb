EventEmitter.apply Sinatra::RocketIO::Linda

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

Sinatra::RocketIO.on :__linda_write do |data, client|
  space, tuple, opts = data
  space = "__default__" if !space.kind_of? String or space.empty?
  opts = {} unless opts.kind_of? Hash
  Sinatra::RocketIO::Linda[space].write tuple, opts
end

Sinatra::RocketIO.on :__linda_read do |data, client|
  space, tuple, callback = data
  space = "__default__" if !space.kind_of? String or space.empty?
  Sinatra::RocketIO::Linda[space].read tuple do |tuple|
    Sinatra::RocketIO.push "__linda_read_#{callback}", tuple.data, :to => client.session
  end
end

Sinatra::RocketIO.on :__linda_take do |data, client|
  space, tuple, callback = data
  space = "__default__" if !space.kind_of? String or space.empty?
  Sinatra::RocketIO::Linda[space].take tuple do |tuple|
    Sinatra::RocketIO.push "__linda_take_#{callback}", tuple.data, :to => client.session
  end
end
