function displayMessage()
{
  if (confirm("Synchronisation will start after closing this box.\nNote that it might take a while depending your Dropbox content, you will be notified when it is over.") == true)
  {
    $('#sync_started').show();
    $('#sync_link').hide();
    $('#hidden_sync').show();
    $('#force_sync').hide();
    $('#hidden_force_sync').show();
    return true;
  }else{
    return false;
  }
}

function checkAllCheckboxes()
{
  var checkboxAll = document.getElementById('check_all');
  var attachmentCheckbox = document.getElementsByName('attachment_checkbox[]');
  if (checkboxAll.checked){
    for (var i = 0; i < attachmentCheckbox.length; i++){
      attachmentCheckbox[i].checked = true;
    }
  }else{
    for (var i = 0; i < attachmentCheckbox.length; i++){
      attachmentCheckbox[i].checked = false;
    }
  }
}
