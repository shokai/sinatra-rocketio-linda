EventEmitter.apply Sinatra::RocketIO::Linda

module Sinatra
  module RocketIO
    module Linda

      def self.read(key, &block)
        self.on key, &block if block_given?
      end

      def self.write(key, value=nil)
        Sinatra::RocketIO.push :__linda, {:key => key, :value => value}
      end

    end
  end
end

Sinatra::RocketIO.on :__linda do |tuple, client|
  Sinatra::RocketIO.push :__linda, tuple
  ::Sinatra::RocketIO::Linda.emit tuple['key'], tuple['value']
end
