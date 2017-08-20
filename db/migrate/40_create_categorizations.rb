class CreateCategorizations < ActiveRecord::Migration[5.1]
  def change
    create_table :categorizations do |t|
      t.references :product,  foreign_key: true, index: true, type: :uuid
      t.references :category, foreign_key: true, index: true
    end
  end
end
