class StatsController < ApplicationController
	def index
		@users = User.all.order(score: :desc)
		@top_users = User.all.order(score: :desc).limit(3)
		@top_guild = Guild.all.order(points: :desc).limit(1)
	end
end
