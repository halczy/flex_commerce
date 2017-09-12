class CreateGeos < ActiveRecord::Migration[5.1]
  def change
    create_table :geos, id: :string do |t|
      t.string :parent_id, foreign_key: true, index: true
      t.string :name, index: true
      t.integer :level

      t.timestamps
    end
  end
end
