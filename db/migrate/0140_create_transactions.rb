class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions, id: :uuid do |t|
      t.monetize   :amount
      t.text       :note
      t.references :transactable, polymorphic: true, type: :uuid, index: true
      t.references :originable,   polymorphic: true, type: :uuid, index: true
      t.references :processable,  polymorphic: true, type: :uuid, index: true

      t.timestamps
    end

    change_column :transactions, :amount_cents, :integer, limit: 8
  end
end
