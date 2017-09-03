class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses, id: :uuid do |t|
      t.string :name
      t.string :country_region
      t.string :province_state
      t.string :city
      t.string :district
      t.string :community
      t.string :street
      t.string :full_address
      t.references :addressable, polymorphic: true, index: true

      t.timestamps
    end
  end
end