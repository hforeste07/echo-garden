class RemoveAbbreviationFromLocations < ActiveRecord::Migration[8.0]
  def change
    remove_column :locations, :abbreviation, :string
  end
end
