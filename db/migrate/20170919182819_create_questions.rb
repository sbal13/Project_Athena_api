class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.string :question_type
      t.string :answer
      t.string :wrong_answers
      t.integer :point_value
      t.string :question
      t.belongs_to :assignment, foreign_key: true
    end
  end
end
