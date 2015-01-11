class SpeedLimitController < ApplicationController
  def show
    lat = params[:lat]
    lng = params[:lng]
    render json: {speed_limit: SpeedLimitService.for_lat_lng(lat, lng)}
  end
end
