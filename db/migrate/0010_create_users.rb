class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid  do |t|
      t.string  :type
      t.string  :name
      t.string  :email
      t.string  :cell_number
      t.integer :member_id
      t.string  :password_digest
      t.string  :remember_digest

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :cell_number,          unique: true
    add_index :users, :member_id,            unique: true
  end
end
