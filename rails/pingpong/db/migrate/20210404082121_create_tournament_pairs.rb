class CreateTournamentPairs < ActiveRecord::Migration[6.1]
  def change
    create_table :tournament_pairs do |t|
      t.references      :tournament
      t.references      :p1
      t.references      :p2
      t.references      :game
      t.boolean         :played, default: true
      t.timestamps
    end
  end
end
