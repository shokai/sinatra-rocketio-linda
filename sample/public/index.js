var io = new RocketIO().connect();
var linda = new Linda(io);

linda.read("foo", function(data){
  console.log("foo!! "+data);
});
