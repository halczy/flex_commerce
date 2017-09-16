class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets, id: :uuid do |t|
      t.monetize   :balance
      t.monetize   :pending
      t.references :user, index: true, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
