class BlackSpotService
  def self.lat_lngs
    CSV.foreach(Rails.root.join("crashes.csv")).map do |row|
      Geokit::LatLng.new(row[1], row[2])
    end
  end
end
