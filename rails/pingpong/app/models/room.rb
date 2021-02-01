class Room < ApplicationRecord
	has_many :room_messages, dependent: :destroy, inverse_of: :room
	has_many :chat_room_members, dependent: :destroy;
	has_many :members, :through => :chat_room_members, :source => :user
	validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 15 }

	def is_room_member?(user)
		if self.members.find_by(id: user.id)
			return true
		end
		return false 
	end
end
