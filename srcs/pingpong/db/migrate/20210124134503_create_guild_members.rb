class CreateGuildMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :guild_members do |t|
      t.boolean :owner, default: :false
      t.boolean :officer, default: :false
      t.references :guild, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
