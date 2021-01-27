class HomeController < ApplicationController
	def index
		if user_signed_in?
			@friends = current_user.friends
			@events = current_user.notifications
		end
	end
end
