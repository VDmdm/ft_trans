class Guild < ApplicationRecord
	
	has_many :guild_members
	has_many :members, :through => :guild_members, :source => :user
	has_many :guild_members_officers, -> { where(officer: true) }, :class_name => :GuildMember
	has_many :officers, :through => :guild_members_officers, :source => :user
	has_one  :guild_members_owner, -> { where(owner: true) }, :class_name => :GuildMember
	has_one  :owner, :through => :guild_members_owner, :source => :user
	has_many :war_initiator, foreign_key: "initiator_id"
	has_many :war_recipient, foreign_key: "recipient_id"
	

	has_many :guild_invites
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
	validates :anagram, length: { maximum: 5, minimum: 5 }, uniqueness: true, format: { with: /\A[A-Z]+\z/, message: "only allows uppercase letters" }
	validates :description, length: { minimum: 15, maximum: 50 }

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

	def wars_ended
		War.where("(initiator_id = ? OR recipient_id = ?) AND (status = 4 OR status = 5)", self.id, self.id)
	end

	def wars_request_received
		War.where("recipient_id = ? AND status = 0", self.id)
	end

	def wars_request_sent
		War.where("initiator_id = ? AND status = 0", self.id)
	end

	def war_active
		war = War.where("(initiator_id = ? OR recipient_id = ?) AND status = 3", self.id, self.id)[0]
		if war
			return war
		else
			return nil
		end
	end

	def in_war?(opponent)
		war = self.war_active
		war && (war.initiator == opponent || war.recipient == opponent)
	end
end
