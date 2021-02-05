// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.


import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"


Rails.start()
Turbolinks.start()
ActiveStorage.start()

$(document).on("turbolinks:load", function() {
		$("#btnSubmit").attr("disabled", true);
		$("#users_search input").keyup(function() {
			$.get($("#users_search").attr("action"), $("#users_search").serialize(), null, "script");
			return false;
		  });
});

window.friend_invites_list_switch = function(sending) {
    if (sending)
    {
        document.getElementById('block-incoming').style.display = 'none';
        document.getElementById('block-sending').style.display = 'block';
        document.getElementById('switch-invites-btn-incoming').className = "";
        document.getElementById('switch-invites-btn-swnding').className = "btn-active";
    }
    else
    {
        document.getElementById('block-incoming').style.display = 'block';
        document.getElementById('block-sending').style.display = 'none';
        document.getElementById('switch-invites-btn-incoming').className = "btn-active";
        document.getElementById('switch-invites-btn-swnding').className = "";
    }
}

window.room_list_switch = function(allrooms) {
  if (allrooms)
  {
      document.getElementById('block-myrooms').style.display = 'none';
      document.getElementById('block-allrooms').style.display = 'block';
      document.getElementById('switch-btn-myrooms').className = "";
      document.getElementById('switch-btn-allrooms').className = "btn-active";
  }
  else
  {
      document.getElementById('block-myrooms').style.display = 'block';
      document.getElementById('block-allrooms').style.display = 'none';
      document.getElementById('switch-btn-myrooms').className = "btn-active";
      document.getElementById('switch-btn-allrooms').className = "";
  }
}

$(document).on("turbolinks:load", function() {
	$('#new_room_message').on('ajax:success', function(a, b,c ) {
	  $(this).find('input[type="text"]').val('');
	});
  });

  $(document).on("turbolinks:load", function() {
    $('#new_direct_message').on('ajax:success', function(a, b,c ) {
      $(this).find('input[type="text"]').val('');
    });
    });
  

  $(document).on("turbolinks:load", function(){
    $('.send-message-button').prop('disabled', true);
    $('#room_message_message').keyup(function(){
        if(this.val != "")
            $('.send-message-button').prop('disabled', false);            
        else
            $('.send-message-button').prop('disabled',true);
    })
});

$(document).on("turbolinks:load", function(){
  $('.send-message-button').prop('disabled', true);
  $('#direct_message_message').keyup(function(){
      if(this.val != "")
          $('.send-message-button').prop('disabled', false);            
      else
          $('.send-message-button').prop('disabled',true);
  })
});