var Linda = function(io, opts){
  var self = this;
  this.io = null;
  if(io === null || typeof io === "undefined"){
    this.io = new RocketIO().connect();
  }
  else{
    this.io = io;
  }
  this.opts = opts || {};
  this.TupleSpace = function(name){
    if(name === null || typeof name !== "string") name = "__default__";
    this.name = name;
    this.linda = self;
    var space = this;
    var make_callback_id = function(){
      return new Date()-0+"_"+Math.floor(Math.random()*1000000);
    };
    this.write = function(tuple, opts){
      if(tuple === null || typeof tuple !== "object") return;
      if(opts === null || typeof opts === "undefined") opts = {};
      self.io.push("__linda_write", [space.name, tuple, opts]);
    };
    this.read = function(tuple, callback){
      if(tuple === null || typeof tuple !== "object") return;
      if(typeof callback !== "function") return;
      var callback_id = make_callback_id();
      self.io.once("__linda_read_callback_"+callback_id, callback);
      self.io.push("__linda_read", [space.name, tuple, callback_id]);
    };
    this.take = function(tuple, callback){
      if(tuple === null || typeof tuple !== "object") return;
      if(typeof callback !== "function") return;
      var callback_id = make_callback_id();
      self.io.once("__linda_take_callback_"+callback_id, callback);
      self.io.push("__linda_take", [space.name, tuple, callback_id]);
    };
    this.watch = function(tuple, callback){
      if(tuple === null || typeof tuple !== "object") return;
      if(typeof callback !== "function") return;
      var callback_id = make_callback_id();
      self.io.on("__linda_watch_callback_"+callback_id, callback);
      self.io.push("__linda_watch", [space.name, tuple, callback_id]);
    };
  };
};
