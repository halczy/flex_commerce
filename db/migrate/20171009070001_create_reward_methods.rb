class CreateRewardMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :reward_methods, id: :uuid do |t|
      t.string  :name
      t.integer :variety
      t.hstore  :settings

      t.timestamps
    end
  end
end
