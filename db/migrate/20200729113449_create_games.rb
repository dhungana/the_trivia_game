class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :name
      t.belongs_to :started_by, :class_name => 'Player'
      t.integer :total_players_num
      t.boolean :has_started
      t.boolean :winner_found
      t.belongs_to :winner, :class_name => 'Player'
      t.boolean :game_ended

      t.timestamps
    end

    create_join_table :games, :players

    create_join_table :games, :questions

  end
end
