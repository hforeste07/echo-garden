# == Schema Information
#
# Table name: locations
#
#  id                :bigint           not null, primary key
#  city              :string
#  country           :string           not null
#  province          :string           not null
#  unique_identifier :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_locations_on_country_province_city  (country,province,city) UNIQUE
#
class Location < ApplicationRecord
  has_many :users

  validates :country, :province, :city, presence: true
  validates :city, uniqueness: { scope: [:country, :province], message: "already exists in this province" }, allow_blank: true

  # Unique identifier helper
  def self.generate_unique_identifier(country_code, state_code, city_name)
    "#{country_code.upcase}-#{state_code.upcase}-#{city_name.parameterize(separator: '_')}"
  end
end
