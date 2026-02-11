class LocationsController < ApplicationController
  # Preload countries + states
  def index
    countries = Location.select(:country).distinct.order(:country).pluck(:country)
    states = Location.select(:country, :province).distinct.order(:country, :province)
    states_by_country = states.group_by(&:country)
    render json: { countries: countries, states: states_by_country }
  end

  # Fetch cities for a given country + state
  def cities
    country = params[:country]
    state = params[:state]
    cities = Location.where(country: country, province: state).order(:city).pluck(:id, :city)
    render json: cities.map { |id, city| { id: id, city: city } }
  end
end
