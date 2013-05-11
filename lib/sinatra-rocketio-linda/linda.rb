EventEmitter.apply Sinatra::RocketIO::Linda

module Sinatra
  module RocketIO
    module Linda

      def self.tuplespace
        @@tuplespace ||= TupleSpace.new
      end

      def self.write(tuple, opts={})
        tuplespace.write tuple, opts
      end

      def self.read(tuple, &block)
        tuplespace.read tuple, &block
      end

      def self.take(tuple, &block)
        tuplespace.take tuple, &block
      end
    end
  end
end

Sinatra::RocketIO.on :__linda_write do |data, client|
  tuple, opts = data
  opts = {} unless opts.kind_of? Hash
  Sinatra::RocketIO::Linda.write tuple, opts
end

Sinatra::RocketIO.on :__linda_read do |data, client|
  tuple, callback = data
  Sinatra::RocketIO::Linda.read tuple do |tuple|
    Sinatra::RocketIO.push "__linda_read_#{callback}", tuple.data
  end
end

Sinatra::RocketIO.on :__linda_take do |data, client|
  tuple, callback = data
  Sinatra::RocketIO::Linda.take tuple do |tuple|
    Sinatra::RocketIO.push "__linda_take_#{callback}", tuple.data
  end
end
