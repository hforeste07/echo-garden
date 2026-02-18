namespace :flora do
  desc "Import plants for targeted states/families"
  task import: :environment do
    PlantsImporter.call
  end
end
