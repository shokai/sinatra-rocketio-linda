var io = new RocketIO().connect();
var linda = new Linda(io);
var ts = new linda.TupleSpace("calc_request_response");

$(function(){
  $("#btn_request").click(function(){
    var query = $("#txt_request").val();
    ts.write(["calc", query]);
  });
});

var take_result = function(){
  ts.take(["calc_result"], function(tuple){
    var result = tuple[1];
    $("#log").prepend( $("<p>").text(result) );
    take_result();
  });
};

io.on("connect", function(){
  take_result();
});
