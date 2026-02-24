class CreateGardens < ActiveRecord::Migration[8.0]
  def change
    create_table :gardens do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.integer :rows, default: 5
      t.integer :columns, default: 5

      t.timestamps
    end
  end
end
