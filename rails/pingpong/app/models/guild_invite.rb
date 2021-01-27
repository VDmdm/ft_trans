class GuildInvite < ApplicationRecord
	
	enum status: [ :pending, :accept, :decline ]
	enum dir: [ :invite, :join_request ]
	belongs_to :guild
	belongs_to :user
	belongs_to :invited_by, class_name: "User", optional: true

end
