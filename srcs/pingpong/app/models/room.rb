class Room < ApplicationRecord
	has_many :room_messages, dependent: :destroy, inverse_of: :room
	has_many :chat_room_members, dependent: :destroy;
	has_many :current_members, -> { where(banned: false) }, :class_name => :ChatRoomMember
	has_many :members, :through => :current_members, :source => :user
	has_many :banned_members, -> { where(banned: true) }, :class_name => :ChatRoomMember
	has_many :banned_users, :through => :banned_members, :source => :user
	has_many :kicked_members, -> { where(kicked: true) }, :class_name => :ChatRoomMember
	has_many :kicked_users, :through => :kicked_members, :source => :user
	has_many :muted_members, -> { where(muted: true) }, :class_name => :ChatRoomMember
	has_many :muted_users, :through => :muted_members, :source => :user
	
	has_many :chat_room_admins, -> { where(admin: true) }, :class_name => :ChatRoomMember
	has_many :admins, :through => :chat_room_admins, :source => :user
	has_one  :chat_room_owner, -> { where(owner: true) }, :class_name => :ChatRoomMember
	has_one  :owner, :through => :chat_room_owner, :source => :user

	validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 15 }

	def is_room_member?(user)
		if self.members.find_by(id: user.id)
			return true
		end
		return false 
	end

	def is_owner?(user)
		if  self.owner.id == user.id
			return true
		end
		return false
	end

	def is_admin?(user)
		if self.admins.find_by(id: user.id)
			return true
		end
		return false
	end

	def is_banned?(user)
		if self.banned_users.find_by(id: user.id)
			return true
		end
		return false
	end

	def is_muted?(user)
		if self.muted_users.find_by(id: user.id)
			return true
		end
		return false
	end
end
