class CreateGuildInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :guild_invites do |t|
      t.references  :guild
      t.references  :user
      t.integer     :status, default: 0
      t.integer     :type, default: 0
      t.references  :invited_by, default: nil

      t.timestamps
    end
  end
end
