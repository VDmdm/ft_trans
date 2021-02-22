class Guild < ApplicationRecord
	
	has_many :guild_members, :dependent => :delete_all
	has_many :members, :through => :guild_members, :source => :user
	has_many :guild_members_officers, -> { where(officer: true) }, :class_name => :GuildMember
	has_many :officers, :through => :guild_members_officers, :source => :user
	has_one  :guild_members_owner, -> { where(owner: true) }, :class_name => :GuildMember
	has_one  :owner, :through => :guild_members_owner, :source => :user
	has_many :war_initiator, foreign_key: "initiator_id"
	has_many :war_recipient, foreign_key: "recipient_id"
	

	has_many :guild_invites, :dependent => :delete_all
	has_many :pending_invites_and_requests, -> { where(status: :pending) }, :class_name => :GuildInvite
	# Pending sending invites
	has_many :pending_invites, -> { where(status: :pending, dir: :invite) }, :class_name => :GuildInvite
	has_many :pending_invites_user, :through => :pending_invites, :source => :user
	# Pending incoming invites
	has_many :pending_join_request, -> { where(status: :pending, dir: :join_request) }, :class_name => :GuildInvite
	has_many :pending_join_request_user, :through => :pending_join_request, :source => :user
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

	def pending_join_requests?(user)
		if self.pending_join_request_user.find_by(id: user.id)
			return true
		end
		return false 
	end

	def pending_invites?(user)
		if self.pending_invites_user.find_by(id: user.id)
			return true
		end
		return false 
	end

	def pending_invites_and_requests?(user)
		if self.pending_join_request_user.find_by(id: user.id) || self.pending_invites_user.find_by(id: user.id)
			return true
		end
		return false 
	end

	def rating
		Guild.order(points: :desc).index(self) + 1
	end

	def wars_all
		War.where("initiator_id = ? OR recipient_id = ?", self.id, self.id)
	end

	def wars_active
		War.where("(initiator_id = ? OR recipient_id = ?) AND NOT status=?", self.id, self.id, 3)
	end
end
