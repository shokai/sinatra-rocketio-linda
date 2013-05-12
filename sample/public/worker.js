var linda = new Linda();
var ts = new linda.TupleSpace("calc_request_response");

var calc = function(){
  ts.take(["calc"], function(tuple){
    var query = tuple[1];
    var result = eval(query);
    $("#log").prepend( $("<p>").text(query+" = "+result).prepend("calc: ") );
    ts.write(["calc_result", result]);
    calc();
  });
};

linda.io.on("connect", function(){
  calc();
});
