class CreateTransfers < ActiveRecord::Migration[5.1]
  def change
    create_table :transfers, id: :uuid do |t|
      t.monetize :amount
      t.integer  :status,         default: 0
      t.integer  :processor
      t.uuid     :transferer_id,  index: true
      t.uuid     :transferee_id,  index: true
      t.uuid     :fund_source,    index: true
      t.uuid     :fund_target,    index: true

      t.timestamps
    end

    change_column :transfers, :amount_cents, :integer, limit: 8
  end
end
