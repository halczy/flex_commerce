class CreateShippingMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :shipping_methods, id: :uuid do |t|
      t.string     :name
      t.integer    :variety
      t.references :product,   foreign_key: true, type: :uuid, index: true
      t.references :inventory, foreign_key: true, type: :uuid, index: { unique: true }

      t.timestamps
    end

    create_table :products_shipping_methods, id: false do |t|
      t.belongs_to :product,         type: :uuid, index: true
      t.belongs_to :shipping_method, type: :uuid, index: true
    end
  end
end
