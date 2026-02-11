class AddUniqueIdentifierToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :unique_identifier, :string
  end
end
