Blacklight.onLoad(function () {

  // change the action based which collection is selected
  // This expects the form to have a path that includes the string 'collection_replace_id'
  $('[data-behavior="updates-collection"]').on('click', function() {
      var string_to_replace = "collection_replace_id"
      var form = $(this).closest("form");
      var collection_id = $(".collection-selector:checked")[0].value;
      form[0].action = form[0].action.replace(string_to_replace, collection_id);
      form.append('<input type="hidden" value="add" name="collection[members]"></input>');
  });

  // Delete collection(s) button click
  $('#delete-collections-button').on('click', function () {
    var tableRows = $('#documents table.collections-list-table tbody tr');
    var checkbox = null;
    var areRowsSelected = false;

    tableRows.each(function(i, row) {
      checkbox = $(row).find('td:first input[type=checkbox]');
      if (checkbox[0].checked) {
        areRowsSelected = true;
      }
    });

    // Collections are selected
    if (areRowsSelected) {
      $('#collections-to-delete-modal').modal('show');
    } else {
      $('#collections-to-delete-deny-modal').modal('show');
    }

  });
});
