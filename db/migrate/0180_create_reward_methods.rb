class CreateRewardMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :reward_methods, id: :uuid do |t|
      t.string     :name
      t.integer    :variety,  index: true
      t.hstore     :settings, default: {}

      t.timestamps
    end

    create_table :products_reward_methods, id: false do |t|
      t.belongs_to :product,       type: :uuid, index: true
      t.belongs_to :reward_method, type: :uuid, index: true
    end
  end
end
