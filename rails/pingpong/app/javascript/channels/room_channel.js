import consumer from "./consumer"

$(document).on("turbolinks:load", function() {
	$('[data-channel-subscribe="room"]').each(function(index, element) {
	  var $element = $(element),
		  room_id = $element.data('room-id'),
	  messageTemplate = $('[data-role="message-template"]');
  
	  $element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000)        
  
	  consumer.subscriptions.create(
		{
		  channel: "RoomChannel",
		  room: room_id
		},
		{
		  received: function(data) {
			var year = data.updated_at.substring(0, 10);
			var time = data.updated_at.substring(11, 19) + " UTC";
			var content = messageTemplate.children().clone(true, true);
			content.find('[data-role="user-avatar"]').attr('src', data.user_avatar);
			content.find('[data-role="user-id"]').attr('href', function() { return $(this).attr("href") + "/"+data.user_id});
			content.find('[data-role="user-nickname"]').text(data.user_nickname);
			if (!data.user_guild)
				content.find('[data-role="user-guild"]').css('display', 'hidden');
			else{
				content.find('[data-role="user-guild"]').text('[' + data.user_guild + ']');
				content.find('[data-role="user-guild-id"]').attr('href', function() { return $(this).attr("href") + "/" + data.user_guild_id});
			}
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