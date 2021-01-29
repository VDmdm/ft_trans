class Room < ApplicationRecord
	has_many :room_messages, dependent: :destroy, inverse_of: :room
	validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 15 }
end
