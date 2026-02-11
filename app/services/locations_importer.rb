require "net/http"
require "json"

class LocationsImporter
  BASE_URL = "https://api.countrystatecity.in/v1"
  API_KEY = ENV["COUNTRY_STATE_CITY_API_KEY"]
  COUNTRY_CODE = "US"

  def self.call
    states = get_request("#{BASE_URL}/countries/#{COUNTRY_CODE}/states")

    states.each do |state|
      state_code = state["iso2"]
      state_name = state["name"]

      cities = get_request("#{BASE_URL}/countries/#{COUNTRY_CODE}/states/#{state_code}/cities")

      cities.each do |city|
        location = Location.find_or_initialize_by(
          country: "United States",
          province: state_name,
          city: city["name"],
        )

        location.unique_identifier = Location.generate_unique_identifier("US", state_code, city["name"])
        location.save!
      end

      puts "Imported cities for #{state_name}"
    end

    puts "Import complete!"
  end

  def self.get_request(url)
    uri = URI(url)
    request = Net::HTTP::Get.new(uri)
    request["X-CSCAPI-KEY"] = API_KEY

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

    puts "Error fetching: #{response.message}"
    []
  end
end
