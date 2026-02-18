class AddStyleToPlants < ActiveRecord::Migration[8.0]
  def change
    add_column :plants, :style, :string
  end
end
