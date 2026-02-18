namespace :plants do
  desc "Import native US plants from Trefle API"
  task import: :environment do
    puts "🌿 Starting plant import at #{Time.current}"

    importer = PlantsImporter.new
    importer.fetch_native_us_plants

    puts "✅ Plant import finished at #{Time.current}"
  rescue => e
    puts "❌ Import failed: #{e.message}"
    puts e.backtrace
  end
end
