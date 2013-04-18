var linda = new Linda();

linda.read("calc", function(query){
  $("#log").prepend( $("<p>").text(query).prepend("calc: ") );
  var result = eval(query);
  linda.write("calc_result", result);
});
