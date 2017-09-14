class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.integer    :status,        index: true, default: 0
      t.monetize   :shipping_cost, default: 0
      t.references :user,          index: true, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
