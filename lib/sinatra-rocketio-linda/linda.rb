module Sinatra
  module RocketIO
    module Linda

      def self.tuplespaces
        @@spaces ||= Hash.new{|h,k| h[k] = TupleSpace.new(k) }
      end

      def self.[](name)
        self.tuplespaces[name]
      end

      def self.check_expire
        tuplespaces.values.each do |ts|
          ts.check_expire
        end
      end

      def self.callbacks
        @@callbacks ||= Hash.new{|h,k| h[k] = Array.new }
      end

    end
  end
end

Sinatra::RocketIO.on :start do
  EM::add_periodic_timer Sinatra::RocketIO::Linda.options[:expire_check] do
    Sinatra::RocketIO::Linda.check_expire
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
  unless opts.kind_of? Hash
    opts = {}
  else
    opts_ = {}
    opts.each do |k,v|
      opts_[k.to_sym] = v
    end
    opts = opts_
  end
  opts[:from] = client.address
  _tuple = Sinatra::RocketIO::Linda::Tuple.new tuple, opts
  Sinatra::RocketIO::Linda[space].write _tuple
  Sinatra::RocketIO::Linda.emit :write, Hashie::Mash.new(:space => space, :tuple => tuple), client
end

[:read, :take, :watch].each do |func|
  Sinatra::RocketIO.on "__linda_#{func}" do |data, client|
    space, tuple, callback = data
    space = "__default__" if !space or !space.kind_of? String or space.empty?
    unless [Hash, Array].include? tuple.class
      Sinatra::RocketIO::Linda.emit :error, "received Tuple is not Hash or Array at :__linda_#{func}"
      next
    end
    if !callback or !callback.kind_of? String or callback.empty?
      Sinatra::RocketIO::Linda.emit :error, "received Callback ID is not valid at :__linda_#{func}"
      next
    end
    callback_id = Sinatra::RocketIO::Linda[space].__send__ func, tuple do |tuple|
      from = tuple.class == Sinatra::RocketIO::Linda::Tuple ? tuple.from : "server"
      Sinatra::RocketIO.push "__linda_#{func}_callback_#{callback}", {:tuple => tuple.data, :info => {:from => from}}, :to => client.session
      Sinatra::RocketIO::Linda.emit func, Hashie::Mash.new(:space => space, :tuple => tuple), client
    end
    Sinatra::RocketIO::Linda.callbacks[client.session].push(:space => space, :callback => callback_id)
  end
end

Sinatra::RocketIO.on :__linda_list do |data, client|
  space, tuple, callback = data
  space = "__default__" if !space or !space.kind_of? String or space.empty?
  unless [Hash, Array].include? tuple.class
    Sinatra::RocketIO::Linda.emit :error, "received Tuple is not Hash or Array at :__linda_list"
    next
  end
  list = Sinatra::RocketIO::Linda[space].list tuple
  Sinatra::RocketIO::Linda.emit :list, list, client
  Sinatra::RocketIO.push "__linda_list_callback_#{callback}", list
end

Sinatra::RocketIO.on :disconnect do |client|
  Sinatra::RocketIO::Linda.callbacks[client.session].each do |i|
    Sinatra::RocketIO::Linda[i[:space]].cancel i[:callback]
  end
end
