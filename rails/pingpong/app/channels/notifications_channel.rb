class NotificationsChannel < ApplicationCable::Channel
	def subscribed
		current_user.update_attribute(:status, :online)
		stream_from "notifications:#{current_user.id}"
	end

	def unsubscribed
		current_user.update_attribute(:status, :offline)
		stop_all_streams
	end
end