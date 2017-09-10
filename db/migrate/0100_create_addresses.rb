class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses, id: :uuid do |t|
      t.string :name
      t.string :recipient
      t.string :contact_number
      t.string :country_region
      t.string :province_state
      t.string :city
      t.string :district
      t.string :community
      t.string :street
      t.string :full_address
      t.references :addressable, polymorphic: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
