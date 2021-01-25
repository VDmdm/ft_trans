class GuildInvite < ApplicationRecord
	enum status: [ :pending, :accept, :decline ]
	enum dir: [ :sending, :incoming ]
	belongs_to :guild
	belongs_to :user
	belongs_to :invited_by, class_name: "User"

end
