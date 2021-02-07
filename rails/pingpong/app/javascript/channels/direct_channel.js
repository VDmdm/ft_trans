import consumer from "./consumer"

$(document).on("turbolinks:load", function() {
	$('[data-channel-subscribe="direct"]').each(function(index, element) {
	  var $element = $(element),
		  room_id = $element.data('room-id'),
	  messageTemplate = $('[data-role="direct-message-template"]');
  
	  $element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000)        
  
	  var channel = consumer.subscriptions.create(
		{
		  channel: "DirectChannel",
		  direct_room: room_id
		},
		{
		  received: function(data) {
			var year = data.updated_at.substring(0, 10);
			var time = data.updated_at.substring(11, 19) + " UTC";
			var content = messageTemplate.children().clone(true, true);
			var current_user = content.find('[data-role="user-id"]').attr('id');
			content.find('[data-role="user-avatar"]').attr('src', data.user_avatar);
			content.find('[data-role="user-id"]').attr('href', function() { return $(this).attr("href") + "/" + data.user_id});
			content.find('[data-role="user-nickname"]').text(data.user_nickname);
			for (var i = 0; i < data.blocked_users.length; i++) {
				if (data.blocked_users[i].id == current_user){
					return;
				}
			}
			if(current_user == data.user_id)	
				content.find('[data-role="message-field"]').css('border', '1px solid #B2D430');
			 if (content.find('[data-role="user-id"]').attr('id') == data.user_id)
				content.find('[data-role="curr_user"]').css('display', 'none');
			if (!data.user_guild)
				content.find('[data-role="user-guild"]').css('display', 'hidden');
			else{
				content.find('[data-role="user-guild"]').text('[' + data.user_guild + ']');
				content.find('[data-role="user-guild-id"]').attr('href', function() { return $(this).attr("href") + "/" + data.user_guild_id});
			}
			content.find('[data-role="block-href"]').attr('href', function() { return $(this).attr("href") + "?blocked_id=" + data.user_id});
			content.find('[data-role="message-text"]').text(data.message);
			content.find('[data-role="message-date"]').text(year + " " + time);
			if (data.message.length != 0)
				$element.append(content);
			$element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000);
		  }
		}
	  );
	});
  });