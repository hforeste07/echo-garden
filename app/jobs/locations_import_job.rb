class LocationsImportJob < ApplicationJob
  queue_as :default

  def perform
    LocationsImporter.call
    Rails.logger.info "Locations import completed at #{Time.current}"
  end
end
