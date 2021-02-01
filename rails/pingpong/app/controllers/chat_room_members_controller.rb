class ChatRoomMembersController < ApplicationController

	def new
		p params
		member = ChatRoomMember.new(user: current_user, room_id: params[:room_id])
		if member.save
			redirect_to room_path(member.room_id)
		else
			redirect_to rooms_path, alert: "Can't join"
		end
	end

	def leave
		record = ChatRoomMember.all.find_by(user: current_user, room_id: params[:room_id])
		p record
		if record.destroy
			redirect_to rooms_path
		else
			redirect_to rooms_path, alert: "Can't join"
		end
	end
end
