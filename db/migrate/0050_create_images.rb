class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images, id: :uuid do |t|
      t.integer    :display_order, default: 0
      t.string     :description
      t.string     :title
      t.boolean    :in_use, default: false
      t.integer    :source_channel
      t.text       :image_data
      t.references :imageable, polymorphic: true, index: true, type: :uuid

      t.timestamps
    end
  end
end
