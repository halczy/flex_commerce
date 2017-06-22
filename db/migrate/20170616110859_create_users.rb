class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :type
      t.string :name
      t.string :email
      t.string :cell_number
      t.string :password_digest, unique: true
      t.string :remember_digest, unique: true

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :cell_number,          unique: true
  end
end
