class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets, id: :uuid do |t|
      t.monetize   :balance,      default: 0
      t.monetize   :pending,      default: 0
      t.monetize   :withdrawable, default: 0
      t.references :user,    index: true, type: :uuid, foreign_key: true

      t.timestamps
    end

    change_column :wallets, :balance_cents,      :integer, limit: 8
    change_column :wallets, :pending_cents,      :integer, limit: 8
    change_column :wallets, :withdrawable_cents, :integer, limit: 8
  end
end
