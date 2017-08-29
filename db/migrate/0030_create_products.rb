class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products, id: :uuid do |t|
      t.string   :name
      t.string   :tag_line
      t.string   :sku
      t.decimal  :weight
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
    add_index :products, :tag_line
    add_index :products, :sku
    add_index :products, :weight
    add_index :products, :price_market_cents
    add_index :products, :price_member_cents
    add_index :products, :price_reward_cents
    add_index :products, :status
  end
end
