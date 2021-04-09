class CreateBlockedUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :blocked_users do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :blocked_id

      t.timestamps
    end
  end
end
