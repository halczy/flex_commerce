class CreateRewardMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :reward_methods, id: :uuid do |t|
      t.string     :name
      t.integer    :variety, index: true
      t.hstore     :settings
      t.references :product, foreign_key: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
