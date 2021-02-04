class DirectMessage < ApplicationRecord
  belongs_to :user
  belongs_to :direct_room
  validates :message, presence: true

end
