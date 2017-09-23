class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.text :description
      t.string :teacher_key
      t.text :subjects, array: true, default: []
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :user_type

      t.timestamps
    end
  end
end
