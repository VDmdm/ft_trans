class RoomMessage < ApplicationRecord
  include Rails.application.routes.url_helpers
  
  belongs_to :room, inverse_of: :room_messages
  belongs_to :user
  validates :message, presence: true
  def as_json(options)
    if (user.guild)
      super(options).merge(user_avatar: rails_blob_path(user.avatar, only_path: true), user_nickname: user.nickname, user_guild: user.guild.anagram, user_guild_id: user.guild.id, banned_users: self.room.banned_users, active_users: self.room.members, muted_users: self.room.muted_users, blocked_users: user.blocked_by)
    else
      super(options).merge(user_avatar: rails_blob_path(user.avatar, only_path: true), user_nickname: user.nickname, banned_users: self.room.banned_users, active_users: self.room.members, muted_users: self.room.muted_users, blocked_users: user.blocked_by)
    end

  end
end
