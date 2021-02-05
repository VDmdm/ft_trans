class DirectMessage < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :direct_room, inverse_of: :direct_messages
  validates :message, presence: true

  def as_json(options)
    if (user.guild)
      super(options).merge(user_avatar: rails_blob_path(user.avatar, only_path: true), user_nickname: user.nickname, user_guild: user.guild.anagram, user_guild_id: user.guild.id, blocked_users: user.blocked_by)
    else
      super(options).merge(user_avatar: rails_blob_path(user.avatar, only_path: true), user_nickname: user.nickname,  blocked_users: user.blocked_by)
    end

  end


end
