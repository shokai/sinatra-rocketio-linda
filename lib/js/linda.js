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
  this.io.on("__linda", function(data){
    self.emit(data['key'], data['value']);
  });
  this.read = function(key, callback){
    if(typeof callback !== "function") return;
    return self.on(key, callback);
  };
  this.write = function(key, value){
    self.io.push("__linda", {key: key, value: value});
  };
};
