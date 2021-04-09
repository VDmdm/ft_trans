class DirectChannel < ApplicationCable::Channel
	def subscribed
	  room = DirectRoom.find params[:direct_room]
	#   if room.is_room_member?(current_user)
		  stream_for room
	#   end
	end

end