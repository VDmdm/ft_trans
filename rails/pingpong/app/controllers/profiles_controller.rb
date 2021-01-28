class ProfilesController < ApplicationController
	before_action :check_user_not_exist, only: [:show]

	def index
		@users = User.search(params[:search]).paginate(:per_page => 10, :page => params[:page])
	end

	def show
		@user = User.find(params[:id])
	end

	private

	def check_user_not_exist
		user = User.all.find_by(id: params[:id])
		redirect_to profiles_path, alert: "User not found" unless user
	end
end
