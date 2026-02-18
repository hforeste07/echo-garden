class CreatePlantNativeRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :plant_native_regions do |t|
      t.references :plant, foreign_key: true
      t.string :wgsrpd_code

      t.timestamps
    end
    add_index :plant_native_regions, :wgsrpd_code
  end
end
