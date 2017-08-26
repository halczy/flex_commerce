class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string     :name
      t.integer    :display_order
      t.integer    :flavor, default: 0
      t.boolean    :hide, default: true
      t.references :parent, index: true

      t.timestamps
    end
  end
end
