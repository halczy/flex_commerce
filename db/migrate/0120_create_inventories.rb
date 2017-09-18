class CreateInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :inventories, id: :uuid do |t|
      t.integer    :status
      t.datetime   :purchased_at
      t.datetime   :returned_at
      t.decimal    :purchase_weight
      t.monetize   :purchase_price
      t.references :user,            index: true, foreign_key: true, type: :uuid
      t.references :product,         index: true, foreign_key: true, type: :uuid
      t.references :cart,            index: true, foreign_key: true, type: :uuid
      t.references :order,           index: true, foreign_key: true, type: :uuid
      t.references :shipping_method, index: true, foreign_key: true, type: :uuid

      t.timestamps
    end

    change_column :inventories, :purchase_price_cents, :integer, limit: 8
  end
end
