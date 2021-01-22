class FriendsController < ApplicationController
  def index

  end

  def search
	@users = User.search(params[:search]).paginate(:per_page => 5, :page => params[:page])
	respond_to do |f|
		f.html
		f.js
	end
  end
  
end
