class AddDefaultGridSizeToGardens < ActiveRecord::Migration[8.0]
  def change
    change_column_default :gardens, :rows, from: nil, to: 5
    change_column_default :gardens, :columns, from: nil, to: 5
  end
end
