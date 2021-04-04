class CreateTournamentPairs < ActiveRecord::Migration[6.1]
  def change
    create_table :tournament_pairs do |t|
      t.references      :tournament
      t.references      :p1
      t.references      :p2
      t.references      :game
      t.integer         :round
      t.boolean         :played, default: false
      t.timestamps
    end
  end
end
