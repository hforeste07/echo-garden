# == Schema Information
#
# Table name: plant_native_regions
#
#  id          :bigint           not null, primary key
#  wgsrpd_code :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  plant_id    :bigint
#
# Indexes
#
#  index_plant_native_regions_on_plant_id     (plant_id)
#  index_plant_native_regions_on_wgsrpd_code  (wgsrpd_code)
#
# Foreign Keys
#
#  fk_rails_...  (plant_id => plants.id)
#
class PlantNativeRegion < ApplicationRecord
  belongs_to :plant

  validates :wgsrpd_code, presence: true
  validates :plant_id, uniqueness: { scope: :wgsrpd_code } # no duplicates
end
