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
  Sinatra::RocketIO::Linda[space].write tuple, opts
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
    eid = Sinatra::RocketIO::Linda[space].__send__ func, tuple do |tuple|
      Sinatra::RocketIO.push "__linda_#{func}_callback_#{callback}", tuple, :to => client.session
      Sinatra::RocketIO::Linda.emit func, Hashie::Mash.new(:space => space, :tuple => tuple), client
    end
    Sinatra::RocketIO.on :disconnect do |_client|
      Sinatra::RocketIO::Linda[space].remove_callback eid if client.session == _client.session
    end
  end
end
