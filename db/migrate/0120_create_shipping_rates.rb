class CreateShippingRates < ActiveRecord::Migration[5.1]
  def change
    create_table :shipping_rates, id: :uuid do |t|
      t.string     :geo_code, index: true
      t.monetize   :init_rate
      t.monetize   :add_on_rate
      t.references :shipping_method, foreign_key: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
