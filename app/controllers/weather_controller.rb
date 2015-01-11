class WeatherController < ApplicationController
  def show
    lat = params[:lat]
    lng = params[:lng]
    render json: {temp: WeatherService.for_lat_lng(lat, lng)}
  end
end
