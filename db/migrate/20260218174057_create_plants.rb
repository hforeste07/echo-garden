class CreatePlants < ActiveRecord::Migration[7.0]
  def change
    create_table :plants do |t|
      t.string :common_name
      t.string :scientific_name, null: false
      t.string :family

      t.string :growth_habit
      t.string :light_requirements
      t.string :blooming_time
      t.string :harvest_time
      t.string :climate
      t.string :watering_needs

      t.string :image_url
      t.string :edible_parts, array: true, default: []

      t.jsonb :raw_data

      t.timestamps
    end

    add_index :plants, :scientific_name, unique: true
  end
end
