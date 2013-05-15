require 'event_emitter'
require 'sinatra/rocketio/client'

module Sinatra
  module RocketIO
    module Linda

      class Client
        attr_reader :io, :tuplespace
        def initialize(io)
          if io.kind_of? String and io =~ /^https?:\/\/.+$/
            @io = Sinatra::RocketIO::Client.new(io).connect
          elsif io.kind_of? Sinatra::RocketIO::Client
            @io = io
          else
            raise ArgumentError, "argument must be URL or RocketIO::Client"
          end
          @tuplespace = Hash.new{|h,k|
            h[k] = Sinatra::RocketIO::Linda::Client::TupleSpace.new(k, self)
          }
        end

        class TupleSpace
          attr_reader :name, :linda
          def initialize(name, linda)
            @name = name
            @linda = linda
          end

          def write(tuple, opts={})
            unless [Hash, Array].include? tuple.class
              raise ArgumentError, "tuple must be Array or Hash"
            end
            @linda.io.push "__linda_write", [@name, tuple, opts]
          end

          def read(tuple, &block)
            unless [Hash, Array].include? tuple.class
              raise ArgumentError, "tuple must be Array or Hash"
            end
            callback_id = "#{Time.now.to_i}#{Time.now.usec}"
            @linda.io.once "__linda_read_callback_#{callback_id}", &block
            @linda.io.push "__linda_read", [@name, tuple, callback_id]
          end

          def take(tuple, &block)
            unless [Hash, Array].include? tuple.class
              raise ArgumentError, "tuple must be Array or Hash"
            end
            callback_id = "#{Time.now.to_i}#{Time.now.usec}"
            @linda.io.once "__linda_take_callback_#{callback_id}", &block
            @linda.io.push "__linda_take", [@name, tuple, callback_id]
          end

          def watch(tuple, &block)
            unless [Hash, Array].include? tuple.class
              raise ArgumentError, "tuple must be Array or Hash"
            end
            callback_id = "#{Time.now.to_i}#{Time.now.usec}"
            @linda.io.on "__linda_watch_callback_#{callback_id}", &block
            @linda.io.push "__linda_watch", [@name, tuple, callback_id]
          end

        end

      end

    end
  end
end
