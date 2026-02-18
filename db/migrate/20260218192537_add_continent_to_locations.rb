class AddContinentToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :continent, :string
  end
end
