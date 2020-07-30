class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.integer :position
      t.belongs_to :trivium
      t.datetime :expires_at
      t.integer :choice1_num
      t.integer :choice2_num
      t.integer :choice3_num
      t.integer :choice4_num
      t.integer :choice5_num
      t.boolean :winner_found

      t.timestamps
    end
  end
end
