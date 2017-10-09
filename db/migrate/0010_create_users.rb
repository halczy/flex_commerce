class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid  do |t|
      t.string  :type
      t.string  :name
      t.string  :email,       index: true, unique: true
      t.string  :cell_number, index: true, unique: true
      t.integer :member_id,   index: true, unique: true
      t.hstore  :setting,     default: {}
      t.string  :password_digest
      t.string  :remember_digest

      t.timestamps
    end
  end
end
