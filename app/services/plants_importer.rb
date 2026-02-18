class PlantsImporter
  BASE_URL = "https://trefle.io/api/v1"

  def initialize
    @token = ENV.fetch("TREFLE_API_KEY")
  end

  # ----------------------------------------
  # Public Entry Point
  # ----------------------------------------
  def fetch_native_us_plants
    us_locations = Location.where(country: "United States")

    puts "🌎 Importing native plants for #{us_locations.count} US regions..."

    us_locations.find_each do |location|
      fetch_plants_for_region(location.wgsrpd_code)
    end

    puts "✅ Native plant import complete."
  end

  private

  # ----------------------------------------
  # Distribution Endpoint (Presence Only)
  # ----------------------------------------
  def fetch_plants_for_region(wgsrpd_code)
    page = 1

    loop do
      response = HTTP.get(
        "#{BASE_URL}/distributions/#{wgsrpd_code}/plants",
        params: { token: @token, page: page }
      )

      break unless response.status.success?

      plants = response.parse["data"]
      break if plants.blank?

      plants.each do |plant_summary|
        import_if_native(plant_summary, wgsrpd_code)
      end

      page += 1
    end

  rescue => e
    puts "⚠️ Error fetching plants for #{wgsrpd_code}: #{e.message}"
  end

  # ----------------------------------------
  # Import + Native Filter
  # ----------------------------------------
  def import_if_native(plant_summary, wgsrpd_code)
    scientific_name = plant_summary["scientific_name"]
    return if scientific_name.blank?

    plant = Plant.find_or_initialize_by(scientific_name: scientific_name)

    # Save minimal data immediately if new
    if plant.new_record?
      plant.common_name = plant_summary["common_name"]
      plant.image_url   = plant_summary["image_url"]
      plant.save!
    end

    # Only fetch detail if never enriched
    detail_data = plant.raw_data || fetch_detail_data(plant_summary["id"])
    return unless detail_data

    species = detail_data["main_species"] || {}

    # 🔎 Native Check
    native_regions = species.dig("distributions", "native") || []

    is_native = native_regions.any? { |r| r["tdwg_code"] == wgsrpd_code }

    return unless is_native

    # Enrich plant only if needed
    if plant.raw_data.blank?
      enrich_plant(plant, detail_data, species)
    end

    # Associate native region
    plant.add_native_region(wgsrpd_code)

    sleep 0.3 # Rate-limit safety
  end

  # ----------------------------------------
  # Fetch Detail Endpoint
  # ----------------------------------------
  def fetch_detail_data(trefle_id)
    response = HTTP.get(
      "#{BASE_URL}/plants/#{trefle_id}",
      params: { token: @token }
    )

    return unless response.status.success?

    response.parse["data"]
  rescue => e
    puts "⚠️ Detail fetch failed: #{e.message}"
    nil
  end

  # ----------------------------------------
  # Enrichment Mapping
  # ----------------------------------------
  def enrich_plant(plant, detail_data, species)
    plant.update!(
      family: species["family"],
      growth_habit: species.dig("specifications", "growth_habit"),
      light_requirements: translate_light(species.dig("growth", "light")),
      blooming_time: format_array(species.dig("growth", "bloom_months")),
      harvest_time: format_array(species.dig("growth", "fruit_months")),
      watering_needs: translate_humidity(species.dig("growth", "soil_humidity")),
      climate: translate_humidity(species.dig("growth", "atmospheric_humidity")),
      edible_parts: species["edible_part"],
      raw_data: detail_data
    )
  end

  # ----------------------------------------
  # Translators
  # ----------------------------------------
  def translate_light(value)
    return nil unless value

    case value.to_i
    when 0..3 then "Full Shade"
    when 4..6 then "Partial Sun"
    when 7..10 then "Full Sun"
    end
  end

  def translate_humidity(value)
    return nil unless value

    case value.to_i
    when 0..3 then "Low"
    when 4..6 then "Medium"
    when 7..10 then "High"
    end
  end

  def format_array(value)
    return nil if value.blank?
    value.map(&:capitalize).join(", ")
  end
end
