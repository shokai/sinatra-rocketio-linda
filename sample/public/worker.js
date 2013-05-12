var linda = new Linda();
var ts = new linda.TupleSpace("calc");

var calc = function(){
  ts.take(["calc_request"], function(tuple){
    var query = tuple[1];
    var result = eval(query);
    $("#log").prepend( $("<p>").text(query+" = "+result).prepend("calc: ") );
    ts.write(["calc_result", result]);
    calc();
  });
};

linda.io.on("connect", calc);
