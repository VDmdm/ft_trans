class GuildsController < ApplicationController
  def index
	@guilds = Guild.all
  end

  def new
	@guild = Guild.new
  end

  def create
	guild = Guild.new(guild_params)
	if guild.save
		guild.guild_members.create(user: current_user, owner: true)
		redirect_to guild_path(guild)
	else
		redirect_to root_path
	end
	
  end

  def show
	p params
	@guild = Guild.all.find(params[:id])
  end

  private
  def guild_params
	params.require(:guild).permit(:name, :description, :anagram, :avatar)
  end

end
