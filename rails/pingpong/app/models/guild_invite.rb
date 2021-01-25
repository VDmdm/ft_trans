class GuildInvite < ApplicationRecord
	enum status: [ :pending, :accept, :decline ]
	enum type: [ :sending, :incoming ]
	belongs_to :guild
	belongs_to :user

end
