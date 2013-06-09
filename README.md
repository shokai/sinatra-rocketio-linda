sinatra-rocketio-linda
======================

* [Linda](https://github.com/shokai/linda-ruby) implementation on [Sinatra::RocketIO](https://github.com/shokai/sinatra-rocketio)
* https://github.com/shokai/sinatra-rocketio-linda


Installation
------------

    % gem install sinatra-rocketio-linda


Requirements
------------
* Ruby 1.8.7 or 1.9.2 or 1.9.3 or 2.0.0
* Sinatra 1.3.0+
* [Sinatra RocketIO](https://github.com/shokai/sinatra-rocketio)
* [EventMachine](http://rubyeventmachine.com)
* [jQuery](http://jquery.com)


Linda
-----
Linda is a coordination launguage for parallel programming.

* http://en.wikipedia.org/wiki/Linda_(coordination_language)
* http://ja.wikipedia.org/wiki/Linda
* https://github.com/shokai/linda-ruby#usage


### TupleSpace
Shared memory on Sinatra.


### Tuple Operations
- write( tuple, options )
  - put a Tuple into the TupleSpace
- take( tuple, callback(tuple) )
  - get a matched Tuple from the TupleSpace and delete
- read( tuple, callback(tuple) )
  - get a matched Tuple from the TupleSpace
- watch( tuple, callback(tuple) )
  - overwatch written Tuples in the TupleSpace

see details on https://github.com/shokai/linda-ruby#usage


Usage
-----

### Setup

Server Side

```ruby
require 'sinatra'
require 'sinatra/rocketio'
require 'sinatra/rocketio/linda'
set :linda, :expire_check => 60

run Sinatra::Application
```

Client Side

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="<%= linda_js %>"></script>
```

```javascript
var io = new RocketIO().connect();
var linda = new Linda(io);
```

### client / worker

client side

```javascript
// create tuplespace
var ts = new linda.TupleSpace("calc");

// request
$("#btn_request").click(function(){
  ts.write(["calc_request", "1-2+3*4"]);
});

// wait result
var take_result = function(){
  ts.take(["calc_result"], function(tuple){
    var result = tuple[1]; // from 'worker' side
    console.log(result);
    take_result(); // recursive call
  });
};
io.on("connect", take_result); // RocketIO's "connect" event
```

worker side

```javascript
// create tuplespace
var ts = new linda.TupleSpace("calc");

// calculate
var calc = function(){
  ts.take(["calc_request"], function(tuple){
    var query = tuple[1]; // => "1-2+3*4"
    var result = eval(query);
    console.log(query+" = "+result); // => "1-2+3*4 = 11"
    ts.write(["calc_result", result]); // return to 'client' side
    calc(); // recursive call
  });
};
io.on("connect", calc); // RocketIO's "connect" event
```

worker side (Ruby)

```ruby
require 'rubygems'
require 'sinatra/rocketio/linda/client'

## create tuplespace
linda = Sinatra::RocketIO::Linda::Client.new 'http://localhost:5000'
ts = linda.tuplespace["calc"]

## calculate
calc = lambda{
  ts.take ["calc_request"] do |tuple|
    query = tuple[1] ## => "1-2+3*4"
    result = eval(query)
    puts "calc: #{query} = #{result}" ## => "1-2+3*4 = 11"
    ts.write ["calc_result", result]  ## return to 'client' side
    calc.call ## recursive call
  end
}

linda.io.on :connect do  ## RocketIO's "connect" event
  puts "connect #{io.session}"
  calc.call
end

linda.wait
```


linda-rocketio command
----------------------

    % lidna-rocketio --help
    % linda-rocketio write -tuple '["say","hello"]' -base http://example.com -space test
    % linda-rocketio read  -tuple '["say","hello"]' -base http://example.com -space test


JavaScript Lib for browser
--------------------------

### Download

- [linda.js](https://raw.github.com/shokai/sinatra-rocketio-linda/master/linda.js)
- [linda.min.js](https://raw.github.com/shokai/sinatra-rocketio-linda/master/linda.min.js)


### Usage

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
<script src="/linda.min.js"></script>
```
```javascript
var io = new RocketIO().connect("http://example.com");
var linda = new Linda(io);

var ts = new linda.TupleSpace("calc");

io.on("connect", function(){
  alert(io.type + " connect!! " + io.session);
  ts.write([1, 2, 3]);
});
```

### Generate JS Lib

    % npm install -g uglify-js
    % gem install bundler
    % bundle install
    % rake jslib

=> linda.js and linda.min.js


Test
----

    % gem install bundler
    % bundle install

start server

    % rake test_server

run test

    % rake test


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
