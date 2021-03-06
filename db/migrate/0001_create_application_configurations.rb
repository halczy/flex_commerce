class CreateApplicationConfigurations < ActiveRecord::Migration[5.1]
  def change
    create_table :application_configurations, id: :uuid do |t|
      t.string  :name, index: true
      t.boolean :status
      t.string  :encrypted_value
      t.string  :encrypted_value_iv
      t.string  :plain

      t.timestamps
    end
  end
end
