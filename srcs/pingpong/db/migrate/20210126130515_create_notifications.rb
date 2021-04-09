class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :recipient_id
      t.string :action
      t.string :notifiable_type
      t.string :service_info

      t.timestamps
    end
  end
end
