class BlackspotsController < ApplicationController
  def near
    lat = params[:lat]
    lng = params[:lng]
    car = Geokit::LatLng.new(lat, lng)
    BlackSpotService.lat_lngs.each do |bs|
      if car.distance_to(bs) <= 0.2
        return render json: {bs: 1}
      end
    end
    render json: {bs: nil}
  end
end
