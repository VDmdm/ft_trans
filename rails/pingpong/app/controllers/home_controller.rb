class HomeController < ApplicationController
  def index
    if user_signed_in?
      @friends = current_user.friends
    end
  end
end
