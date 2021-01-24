class HomeController < ApplicationController
  def index
	@friends = current_user.friends
  end
end
