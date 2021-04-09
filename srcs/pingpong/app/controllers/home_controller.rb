class HomeController < ApplicationController
	def index
		if user_signed_in?
			@friends = current_user.friends
			@live_games = Game.where("status = 0")
		end
	end
end
