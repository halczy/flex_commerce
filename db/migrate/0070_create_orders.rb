class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.integer    :status,          index: true, default: 0
      t.monetize   :shipping_cost,   default: 0
      t.string     :tracking_number
      t.references :user,            index: true, foreign_key: true, type: :uuid

      t.timestamps
    end

    change_column :orders, :shipping_cost_cents, :integer, limit: 8
  end
end
