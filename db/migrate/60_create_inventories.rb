class CreateInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :inventories, id: :uuid do |t|
      t.references :user,    foreign_key: true, index: true, type: :uuid
      t.references :product, foreign_key: true, index: true, type: :uuid
      t.integer    :status
      t.datetime   :purchased_at
      t.datetime   :returned_at

      t.timestamps
    end
  end
end
