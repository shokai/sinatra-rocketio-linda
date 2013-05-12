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
  tuple, opts = data
  opts = {} unless opts.kind_of? Hash
  Sinatra::RocketIO::Linda["__default"].write tuple, opts
end

Sinatra::RocketIO.on :__linda_read do |data, client|
  tuple, callback = data
  Sinatra::RocketIO::Linda["__default"].read tuple do |tuple|
    Sinatra::RocketIO.push "__linda_read_#{callback}", tuple.data, :to => client.session
  end
end

Sinatra::RocketIO.on :__linda_take do |data, client|
  tuple, callback = data
  Sinatra::RocketIO::Linda["__default"].take tuple do |tuple|
    Sinatra::RocketIO.push "__linda_take_#{callback}", tuple.data, :to => client.session
  end
end
