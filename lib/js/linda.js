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
  new EventEmitter().apply(this);
  this.read = function(key, callback){
    if(typeof callback !== "function") return;
    return self.on(key, callback);
  };
  this.write = function(tuple, opts){
    self.io.push("__linda_write", [tuple, opts]);
  };
  this.read = function(tuple, callback){
    if(typeof callback !== "function") return;
    var callback_id = new Date()-0;
    self.io.once("__linda_read_"+callback_id, callback);
    self.io.push("__linda_read", [tuple, callback_id]);
  };
  this.take = function(tuple, callback){
    if(typeof callback !== "function") return;
    var callback_id = new Date()-0;
    self.io.once("__linda_take_"+callback_id, callback);
    self.io.push("__linda_take", [tuple, callback_id]);
  };
};
