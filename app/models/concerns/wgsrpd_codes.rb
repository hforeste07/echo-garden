module WgsrpdCodes
  extend ActiveSupport::Concern

  # WGSRPD Level 2 codes for U.S. states and territories
  WGSRPD_CODES = {
    "Alabama" => "ALA",
    "Alaska" => "ALB",
    "Arizona" => "ARI",
    "Arkansas" => "ARK",
    "California" => "CAL",
    "Colorado" => "COL",
    "Connecticut" => "CON",
    "Delaware" => "DEL",
    "Florida" => "FLA",
    "Georgia" => "GEO",
    "Hawaii" => "HAW",
    "Idaho" => "IDA",
    "Illinois" => "ILL",
    "Indiana" => "IND",
    "Iowa" => "IOW",
    "Kansas" => "KAN",
    "Kentucky" => "KEN",
    "Louisiana" => "LOU",
    "Maine" => "MAI",
    "Maryland" => "MAR",
    "Massachusetts" => "MAS",
    "Michigan" => "MIC",
    "Minnesota" => "MIN",
    "Mississippi" => "MIS",
    "Missouri" => "MOU",
    "Montana" => "MON",
    "Nebraska" => "NEB",
    "Nevada" => "NEV",
    "New Hampshire" => "NHA",
    "New Jersey" => "NJE",
    "New Mexico" => "NME",
    "New York" => "NYO",
    "North Carolina" => "NCA",
    "North Dakota" => "NDA",
    "Ohio" => "OHI",
    "Oklahoma" => "OKL",
    "Oregon" => "ORE",
    "Pennsylvania" => "PEN",
    "Rhode Island" => "RHO",
    "South Carolina" => "SCA",
    "South Dakota" => "SDA",
    "Tennessee" => "TEN",
    "Texas" => "TEX",
    "Utah" => "UTA",
    "Vermont" => "VER",
    "Virginia" => "VIR",
    "Washington" => "WAS",
    "West Virginia" => "WVA",
    "Wisconsin" => "WIS",
    "Wyoming" => "WYO",
    "American Samoa" => "ASM",
    "Guam" => "GUA",
    "Northern Mariana Islands" => "NMI",
    "Puerto Rico" => "PUR",
    "United States Virgin Islands" => "VIR"
  }.freeze

  # Returns WGSRPD code for a location instance
  def wgsrpd_code
    return nil unless country == "United States"
    WGSRPD_CODES[province]
  end

  # Class methods
  module ClassMethods
    # Get all WGSRPD codes for a given state
    def wgsrpd_codes_for_province(province_name)
      where(province: province_name).map(&:wgsrpd_code).compact.uniq
    end
  end

  # Make ClassMethods available on the model
  included do
    extend ClassMethods
  end
end
