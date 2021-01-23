class FriendsController < ApplicationController
  
	before_action :check_add_user_params, only: [:add]
  
	def index
	  @user = current_user
	  @user_friends = current_user.friends
	  @pending_invites = @user.pending_invitations
	  @invites = Invitation.where(user_id: 1, confirmed: false)
	end
  
	def search
	  @users = User.search(params[:search]).paginate(:per_page => 20, :page => params[:page])
	  respond_to do |f|
		  f.html
		  f.js
	  end
	end
  
	def add
	  @user = User.all.find(params[:user_id])
	  @friends = current_user.send_friend_invite(@user)
	  redirect_to(friends_path)
	end
  
	def update
	  inv = Invitation.all.find(params[:inv_id])
  
	  inv.update(confirmed: true)
	  redirect_to(friends_path)
	end
	
	def destroy
	  inv = Invitation.all.find(params[:inv_id])
  
	  inv.destroy
	  redirect_to(friends_path)
	end
  
	private
	def check_add_user_params
	  user = User.all.find_by(id: params[:user_id])
	  if !user
		  redirect_back fallback_location: friends_search_path, alert: "User not found!" and return
	  end
	end
	
  end
  
  