class CreateGuilds < ActiveRecord::Migration[6.1]
  def change
    create_table :guilds do |t|
      t.string :name
      t.string :anagram
      t.string :description
      t.integer :points, default: 1000

      t.timestamps
    end
  end
end
