class CreateChatRoomMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_room_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.boolean :owner, default: :false
      t.boolean :admin, default: :false
      t.boolean :banned, default: :false
      t.boolean :kicked, default: :false
      t.boolean :muted, default: :false

      t.timestamps
    end
  end
end
