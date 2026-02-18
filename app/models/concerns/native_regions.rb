module NativeRegions
  extend ActiveSupport::Concern

  included do
    has_many :plant_native_regions, dependent: :destroy
  end

  # Add a WGSRPD code to a plant
  def add_native_region(code)
    plant_native_regions.find_or_create_by(wgsrpd_code: code)
  end

  # Return array of all WGSRPD codes
  def native_regions_codes
    plant_native_regions.pluck(:wgsrpd_code)
  end
end
