require File.expand_path 'version', File.dirname(__FILE__)
require 'event_emitter'
require 'hashie'
require 'sinatra/rocketio/client'

module Sinatra
  module RocketIO
    module Linda

      class TupleInfo < Hashie::Mash
      end

      class Client
        attr_reader :io, :tuplespace
        def initialize(io_or_url)
          if io_or_url.kind_of? String and io_or_url =~ /^https?:\/\/.+$/
            @io = Sinatra::RocketIO::Client.new(io_or_url).connect
          elsif io_or_url.kind_of? ::Sinatra::RocketIO::Client
            @io = io_or_url
          else
            raise ArgumentError, "argument must be URL or RocketIO::Client"
          end
          @tuplespace = Hash.new{|h,k|
            h[k] = Sinatra::RocketIO::Linda::Client::TupleSpace.new(k, self)
          }
        end

        def wait(&block)
          loop do
            sleep 1
            yield if block_given?
          end
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
            callback_id = create_callback_id
            if block_given?
              @linda.io.once "__linda_read_callback_#{callback_id}" do |data|
                block.call(data['tuple'], TupleInfo.new(data['info']))
              end
            end
            @linda.io.push "__linda_read", [@name, tuple, callback_id]
          end

          def take(tuple, &block)
            unless [Hash, Array].include? tuple.class
              raise ArgumentError, "tuple must be Array or Hash"
            end
            callback_id = create_callback_id
            if block_given?
              @linda.io.once "__linda_take_callback_#{callback_id}" do |data|
                block.call(data['tuple'], TupleInfo.new(data['info']))
              end
            end
            @linda.io.push "__linda_take", [@name, tuple, callback_id]
          end

          def watch(tuple, &block)
            unless [Hash, Array].include? tuple.class
              raise ArgumentError, "tuple must be Array or Hash"
            end
            callback_id = create_callback_id
            if block_given?
              @linda.io.on "__linda_watch_callback_#{callback_id}" do |data|
                block.call(data['tuple'], TupleInfo.new(data['info']))
              end
            end
            @linda.io.push "__linda_watch", [@name, tuple, callback_id]
          end

          private
          def create_callback_id
            "#{Time.now.to_i}#{Time.now.usec}_#{(rand*1000000).to_i}"
          end

        end

      end

    end
  end
end
