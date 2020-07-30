class CreateTrivia < ActiveRecord::Migration[6.0]
  def change
    create_table :trivia do |t|
      t.string :text
      t.string :correct_answer
      t.string :choice1
      t.string :choice2
      t.string :choice3
      t.string :choice4

      t.timestamps
    end
  end
end
