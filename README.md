sinatra-rocketio-linda
======================

* Linda implementation on Sinatra::RocketIO
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


Usage
-----

### Setup

Server Side

```ruby
require 'sinatra'
require 'sinatra/rocketio'
require 'sinatra/rocketio/linda'
set :linda, :check_expire => 60

run Sinatra::Application
```

Client Side

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="<%= rocketio_js %>"></script>
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

Test
----

    % gem install bundler
    % bundle install
    % rake test


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
