class FriendsController < ApplicationController
  
	before_action :check_add_user_params, only: [:add]
	before_action :check_if_friend, only: [:add]

	def index
		#@user = current_user
		@friends = current_user.friends
		@pending_invites = current_user.pending_invitations
		@sending_invites = Invitation.where(user_id: current_user.id, confirmed: false)
	end
  
	def search
		@users = User.search(params[:search]).order(:nickname).paginate(:per_page => 20, :page => params[:page])
		respond_to do |f|
			f.html
			f.js
		end
	end
  
	def add
		@user = User.all.find(params[:user_id])
		@friends = current_user.send_friend_invite(@user)
		redirect_back fallback_location: friends_path, success: "Request successfully sent"
	end
  
	def update
		inv = Invitation.all.find(params[:inv_id])
  
		inv.update(confirmed: true)
		redirect_back fallback_location: friends_path, success: "Successfully added"
	end
	
	def destroy
	  inv = Invitation.all.find(params[:inv_id])
  
	  inv.destroy
	  redirect_back fallback_location: friends_path, success: "Friendship successfully destroyed"
	end
  
	private
	def check_add_user_params
	  	user = User.all.find_by(id: params[:user_id])
	  	if !user
			redirect_back fallback_location: friends_search_path, alert: "User not found!" and return
	  	elsif user == current_user
			redirect_back fallback_location: friends_search_path, alert: "Can create friendship with self!" and return
		end
	end

	def check_if_friend
		user = User.all.find_by(id: params[:user_id])
		if current_user.friends_with?(user) || Invitation.pending?(current_user.id, user.id)
			redirect_back fallback_location: friends_search_path, alert: "Already friend" and return
		end
	end
	
  end
  
  