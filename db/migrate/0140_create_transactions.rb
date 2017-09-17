class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions, id: :uuid do |t|
      t.monetize   :amount
      t.integer    :variety
      t.integer    :status
      t.text       :note
      t.jsonb      :metadata
      t.references :transactable, polymorphic: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
