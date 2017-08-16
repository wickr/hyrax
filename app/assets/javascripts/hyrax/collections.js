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

  // Delete collections button click
  $('#delete-collections-button').on('click', function () {
    var tableRows = $('#documents table.collections-list-table tbody tr');
    var checkbox = null;
    var numRowsSelected = false;
    var deleteWording = {
      plural: 'Deleting these collections',
      singular: 'Deleting this collection'
    };
    var $deleteWordingTarget = $('#collections-to-delete-modal .pluralized');

    tableRows.each(function(i, row) {
      checkbox = $(row).find('td:first input[type=checkbox]');
      if (checkbox[0].checked) {
        numRowsSelected++;
      }
    });

    // Collections are selected
    if (numRowsSelected > 0) {
      // Update singular / plural text in delete modal
      if (numRowsSelected > 1) {
        $deleteWordingTarget.text(deleteWording.plural);
      } else {
        $deleteWordingTarget.text(deleteWording.singular);
      }
      $('#collections-to-delete-modal').modal('show');
    } else {
      $('#collections-to-delete-deny-modal').modal('show');
    }

  });


});
