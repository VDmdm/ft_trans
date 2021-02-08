class CreateDirectMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :direct_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :direct_room, null: false, foreign_key: true
      t.text :message

      t.timestamps
    end
  end
end
