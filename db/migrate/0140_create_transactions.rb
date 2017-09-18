class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions, id: :uuid do |t|
      t.monetize   :amount
      t.text       :note
      t.references :transactable, polymorphic: true, type: :uuid, index: true
      t.references :origin,       polymorphic: true, type: :uuid, index: true
      t.references :processor,    polymorphic: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
