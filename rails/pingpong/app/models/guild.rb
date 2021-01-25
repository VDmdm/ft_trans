class Guild < ApplicationRecord
	
	has_many :guild_members, :dependent => :delete_all
	has_many :members, :through => :guild_members, :source => :user
	has_many :guild_members_officers, -> { where(officer: true) }, :class_name => :GuildMember
	has_many :officers, :through => :guild_members_officers, :source => :user
	has_one  :guild_members_owner, -> { where(owner: true) }, :class_name => :GuildMember
	has_one  :owner, :through => :guild_members_owner, :source => :user

	has_many :guild_invites, :dependent => :delete_all
	# Pending sending invites
	has_many :pending_sending_invites, -> { where(status: :pending, dir: :sending) }, :class_name => :GuildInvite
	has_many :pending_sending_invites_user, :through => :pending_sending_invites, :source => :user
	# Pending incoming invites
	has_many :pending_incoming_invites, -> { where(status: :pending, dir: :incoming) }, :class_name => :GuildInvite
	has_many :pending_incoming_invites_user, :through => :pending_incoming_invites, :source => :user
	# accepted invites
	has_many :accepted_invites, -> { where(status: :accept) }, :class_name => :GuildInvite
	has_many :accepted_invites_user, :through => :accepted_invites, :source => :user
	# declined invites
	has_many :declined_invites, -> { where(status: :decline) }, :class_name => :GuildInvite
	has_many :declined_invites_user, :through => :declined_invites, :source => :user

	has_one_attached :avatar
	validates :avatar, attached: true, allow_blank: false, content_type: [:png, :jpg, :jpeg, :gif],
		size: { less_than: 10.megabytes , message: 'filesize to big' }

	validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 15 }
	validates :anagram, presence: true, uniqueness: true, length: { is: 5 }
	validates :description, length: { maximum: 100 }

end
