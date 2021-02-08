class RoomChannel < ApplicationCable::Channel
	def subscribed
	  room = Room.find params[:room]
	  if room.is_room_member?(current_user)
		  stream_for room
	  end
	end

	def unsubscribed
		room = Room.find params[:room]
		stop_stream_for room
	  end
end