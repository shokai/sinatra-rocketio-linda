module Sinatra
  module RocketIO
    module Linda

      class Tuple
        attr_reader :data, :type, :expire_at
        def initialize(data, opts={})
          unless [Array, Hash].include? data.class
            raise ArgumentError, 'argument must be instance of Array or Hash'
          end
          @data = data
          @type = data.class
          @expire_at = Time.now+(opts[:expire] || 300)
        end

        def match?(target)
          raise ArgumentError, 'argument must be instance of Tuple' unless target.kind_of? self.class
          return false if @type != target.type
          if @type == Array
            return false if @data.length > target.data.length
            @data.each_with_index do |v,i|
              return false if target.data[i] != v
            end
            return true
          elsif @type == Hash
            @data.each do |k,v|
              return false if target.data[k] != v
            end
            return true
          end
          false
        end

        def to_s
          @data.to_s
        end
      end

      class TupleSpace
        include Enumerable

        def initialize
          @tuples = Array.new
          @callbacks = Array.new
        end

        def each(&block)
          @tuples.each do |tp|
            yield tp
          end
        end

        def size
          @tuples.size
        end

        DEFAULT_WRITE_OPTIONS = {
          :expire => 300
        }

        def write(tuple, opts=DEFAULT_WRITE_OPTIONS)
          tuple = Tuple.new tuple, opts unless tuple.kind_of? Tuple
          called = nil
          @callbacks.each do |callback|
            next unless callback[:tuple].match? tuple
            if callback[:type] == :read
              callback[:callback].call tuple
            elsif callback[:type] == :take
            end
            called = callback
            break
          end
          @callbacks.delete called if called
          @tuples.unshift tuple
          tuple
        end

        def read(tuple, &block)
          tuple = Tuple.new tuple unless tuple.kind_of? Tuple
          @tuples.each do |t|
            if tuple.match? t
              if block_given?
                block.call t
              else
                return t
              end
            end
          end
          @callbacks.push(:type => :read, :callback => block, :tuple => tuple) if block_given?
        end

        def take(tuple, &block)
          return unless tp = read(tuple)
          @tuples.delete tp
        end

        def check_expire
          expires = []
          each do |tuple|
            expires.push tuple unless tuple.expire_at > Time.now
          end
          expires.each do |tuple|
            @tuples.delete tuple
          end
        end
      end

    end
  end
end
