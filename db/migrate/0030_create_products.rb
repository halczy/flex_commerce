class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products, id: :uuid do |t|
      t.string   :name
      t.string   :tag_line
      t.string   :sku
      t.text     :introduction
      t.text     :description
      t.text     :specification
      t.monetize :price_market
      t.monetize :price_member
      t.monetize :price_reward
      t.monetize :cost
      t.boolean  :strict_inventory, default: true
      t.boolean  :digital,          default: false
      t.integer  :status,           default: 1

      t.timestamps
    end

    add_index :products, :name
    add_index :products, :sku
  end
end
