class CreateInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :inventories do |t|
      t.references :user, foreign_key: true, index: true
      t.references :product, foreign_key: true, index: true
      t.integer :status
      t.datetime :purchased_at
      t.datetime :returned_at

      t.timestamps
    end
  end
end
