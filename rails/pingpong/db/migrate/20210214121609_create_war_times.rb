class CreateWarTimes < ActiveRecord::Migration[6.1]
  def change
    create_table :war_times do |t|
      t.belongs_to :war
      t.references :game
      t.boolean    :p1_accept, default: false
      t.boolean    :p2_accept, default: false
      t.references :winner
      t.integer    :status, default: 0
      t.timestamps
    end
  end
end
