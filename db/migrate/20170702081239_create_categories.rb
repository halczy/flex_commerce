class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string  :name
      t.integer :display_order
      t.integer :level
      t.boolean :hide, default: true

      t.timestamps
    end
  end
end
