namespace :locations do
  desc "Import locations from external API"
  task import: :environment do
    LocationsImporter.call
    puts "Locations imported successfully"
  end
end
