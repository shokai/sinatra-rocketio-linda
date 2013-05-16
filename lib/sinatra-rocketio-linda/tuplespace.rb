module Sinatra
  module RocketIO
    module Linda

      class TupleSpace
        include Enumerable
        attr_reader :name

        def initialize(name="__default__")
          @name = name
          @tuples = Array.new
          @callbacks = Array.new
        end

        def each(&block)
          @tuples.each do |tp|
            yield tp
          end
        end

        def remove_callback(callback)
          @callbacks.delete callback
        end

        def size
          @tuples.size
        end

        DEFAULT_WRITE_OPTIONS = {
          :expire => 300
        }

        def write(tuple, opts={})
          raise ArgumentError, "options must be Hash" unless opts.kind_of? Hash
          DEFAULT_WRITE_OPTIONS.each do |k,v|
            opts[k] = v unless opts.include? k
          end
          tuple = Tuple.new tuple, opts unless tuple.kind_of? Tuple
          calleds = []
          taked = nil
          @callbacks.each do |callback|
            next unless callback[:tuple].match? tuple
            callback[:callback].call tuple
            calleds.push callback unless callback[:type] == :watch
            if callback[:type] == :take
              taked = tuple
              break
            end
          end
          calleds.each do |called|
            @callbacks.delete called
          end
          @tuples.unshift tuple unless taked
          tuple
        end

        def read(tuple, &block)
          tuple = Tuple.new tuple unless tuple.kind_of? Tuple
          @tuples.each do |t|
            if tuple.match? t
              if block_given?
                block.call t
                return
              else
                return t
              end
            end
          end
          if block_given?
            callback = {:type => :read, :callback => block, :tuple => tuple}
            @callbacks.push callback
            return callback
          end
        end

        def take(tuple, &block)
          tuple = Tuple.new tuple unless tuple.kind_of? Tuple
          matched_tuple = nil
          @tuples.each do |t|
            if tuple.match? t
              matched_tuple = t
              break
            end
          end
          if matched_tuple
            @tuples.delete matched_tuple
            if block_given?
              block.call matched_tuple
            else
              return matched_tuple
            end
          else
            if block_given?
              callback = {:type => :take, :callback => block, :tuple => tuple}
              @callbacks.push callback
              return callback
            end
          end
        end

        def watch(tuple, &block)
          raise ArgumentError, "block not given" unless block_given?
          tuple = Tuple.new tuple unless tuple.kind_of? Tuple
          callback = {:type => :watch, :callback => block, :tuple => tuple}
          @callbacks.unshift callback
          callback
        end

        def check_expire
          expires = []
          self.each do |tuple|
            expires.push(tuple) if tuple.expire_at and tuple.expire_at < Time.now
          end
          expires.each do |tuple|
            @tuples.delete tuple
          end
        end
      end

    end
  end
end
