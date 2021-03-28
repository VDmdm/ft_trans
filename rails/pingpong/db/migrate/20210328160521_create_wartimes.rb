class CreateWartimes < ActiveRecord::Migration[6.1]
  def change
    create_table :wartimes do |t|
      t.references  :war
      t.references  :game
      t.references  :guild_1
      t.references  :guild_2
      t.references  :winner
      t.boolean     :active, default: true
      t.timestamps
    end
  end
end
