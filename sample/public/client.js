var io = new RocketIO().connect();
var linda = new Linda(io);

$(function(){
  $("#btn_request").click(function(){
    var query = $("#txt_request").val();
    linda.write("calc", query);
  });
});

linda.read("calc_result", function(result){
  $("#log").prepend( $("<p>").text(result) );
});
