require 'event_emitter'
require 'sinatra/rocketio/client'

module Sinatra
  module RocketIO
    module Linda
      class Client
        include EventEmitter
        attr_reader :io
        def initialize(url)
          this = self
          @io = Sinatra::RocketIO::Client.new url
          @io.on :__linda do |tuple|
            this.emit tuple['key'], tuple['value']
          end
          @io.on :connect do
            this.emit :connect, @io
          end
          @io.on :disconnect do
            this.emit :disconnect, @io
          end
          @io.on :error do |err|
            this.emit :error, err
          end
          self
        end

        def connect
          @io.connect
          self
        end

        def read(key, &block)
          self.on key, &block if block_given?
        end

        def write(key, value)
          @io.push :__linda, {:key => key, :value => value}
        end

      end
    end
  end
end
