class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products, id: :uuid do |t|
      t.string   :name,             index: true
      t.string   :tag_line,         index: true
      t.string   :sku,              index: true
      t.decimal  :weight,           index: true
      t.text     :introduction
      t.text     :description
      t.text     :specification
      t.monetize :price_market,     index: true
      t.monetize :price_member,     index: true
      t.monetize :price_reward,     index: true
      t.monetize :cost,             index: true
      t.boolean  :strict_inventory, default: true
      t.boolean  :digital,          default: false
      t.integer  :status,           default: 1, index: true

      t.timestamps
    end

    change_column :products, :price_market_cents, :integer, limit: 8
    change_column :products, :price_member_cents, :integer, limit: 8
    change_column :products, :price_reward_cents, :integer, limit: 8
  end
end
