class CreateGardenPlots < ActiveRecord::Migration[8.0]
  def change
    create_table :garden_plots do |t|
      t.references :garden, foreign_key: true
      t.references :plant, foreign_key: true
      t.integer :row
      t.integer :column

      t.timestamps
    end
  end
end
