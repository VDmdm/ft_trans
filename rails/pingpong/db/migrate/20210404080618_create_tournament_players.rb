class CreateTournamentPlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :tournament_players do |t|
      t.references        :tournament
      t.references        :player
      t.integer           :score, default: 0
      t.boolean           :winner
      t.timestamps
    end
  end
end
