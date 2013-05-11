var linda = new Linda();

var calc = function(){
  linda.take(["calc"], function(tuple){
    var query = tuple[1];
    $("#log").prepend( $("<p>").text(query).prepend("calc: ") );
    var result = eval(query);
    linda.write(["calc_result", result]);
    calc();
  });
};

linda.io.on("connect", function(){
  calc();
});
