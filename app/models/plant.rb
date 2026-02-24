# == Schema Information
#
# Table name: plants
#
#  id                 :bigint           not null, primary key
#  blooming_time      :string
#  climate            :string
#  common_name        :string
#  edible_parts       :string           default([]), is an Array
#  family             :string
#  growth_habit       :string
#  harvest_time       :string
#  image_url          :string
#  light_requirements :string
#  raw_data           :jsonb
#  scientific_name    :string           not null
#  style              :string
#  watering_needs     :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_plants_on_scientific_name  (scientific_name) UNIQUE
#
class Plant < ApplicationRecord
  has_many :plant_native_regions, dependent: :destroy
  has_many :native_regions,
           through: :plant_native_regions,
           source: :location

  has_many :garden_plots, dependent: :nullify
  has_many :gardens, through: :garden_plots

  validates :scientific_name, presence: true, uniqueness: true

  def add_native_region(wgsrpd_code)
    location = Location.find_by(wgsrpd_code: wgsrpd_code)
    return unless location

    plant_native_regions.find_or_create_by(location: location)
  end
end
