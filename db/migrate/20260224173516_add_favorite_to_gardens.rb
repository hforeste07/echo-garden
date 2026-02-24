class AddFavoriteToGardens < ActiveRecord::Migration[8.0]
  def change
    add_column :gardens, :favorite, :boolean, default: false, null: false
  end
end
