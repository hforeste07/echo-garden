# == Schema Information
#
# Table name: garden_plots
#
#  id         :bigint           not null, primary key
#  column     :integer
#  row        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  garden_id  :bigint
#  plant_id   :bigint
#
# Indexes
#
#  index_garden_plots_on_garden_id  (garden_id)
#  index_garden_plots_on_plant_id   (plant_id)
#
# Foreign Keys
#
#  fk_rails_...  (garden_id => gardens.id)
#  fk_rails_...  (plant_id => plants.id)
#
class GardenPlot < ApplicationRecord
  belongs_to :garden
  belongs_to :plant, optional: true

  validates :row, :column, presence: true
end
