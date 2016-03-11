$( document ).ready(function() {
  console.log( "ready!" );

  $("#more-ingredients").click(function () {
    var $lastRow = $("#ingredients-table tr:last");
    for (var i = 0; i < 3; i++) {
      var $newRow = $lastRow.clone();
      $newRow.find(':input').val('');
      $("#ingredients-table tbody").append($newRow);
    }
  });

  $("#more-steps").click(function () {
    for (var i = 0; i < 3; i++) {
      var $step = $("div.step:last");
      var $newStep = $step.clone();
      $newStep.find(':input').val('');
      var newNumber = Number($newStep.find('.input-group-addon').text()) + 1;
      $newStep.find('.input-group-addon').text(newNumber + '.');
      $step.after($newStep);
    }
  });

  $("#delete-button").click(function () {
    $(this).hide();
    $("#am-sure-or-cancel-zone").show();
  });

  $("#cancel-delete").click(function() {
    $("#am-sure-or-cancel-zone").hide();
    $("#delete-button").show();
  });


});
