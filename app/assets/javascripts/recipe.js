$( document ).ready(function() {
  console.log( "ready!" );

  $("#more-ingredients").click(function () {
    var $lastRow = $("#ingredients-table tr:last");
    for (var i = 0; i < 3; i++) {
      var $newRow = $lastRow.clone();
      $("#ingredients-table tbody").append($newRow);
    }
  });


});
