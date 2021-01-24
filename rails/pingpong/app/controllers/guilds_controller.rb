class GuildsController < ApplicationController

  before_action :check_user_guild_exist, only: [:create]

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

  def check_user_guild_exist
	redirect_to guild_path(current_user.guild), allert: "You allready have a guild" if current_user.guild
  end

end
