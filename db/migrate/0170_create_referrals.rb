class CreateReferrals < ActiveRecord::Migration[5.1]
  def change
    create_table :referrals, id: :uuid do |t|
      t.uuid :referer_id, index: true
      t.uuid :referee_id, index: true, unique: true

      t.timestamps
    end
  end
end
