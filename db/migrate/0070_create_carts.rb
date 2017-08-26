class CreateCarts < ActiveRecord::Migration[5.1]
  def change
    create_table :carts, id: :uuid do |t|
      t.references :user, foreign_key: true, index: true, type: :uuid
      t.integer    :status

      t.timestamps
    end
  end
end
