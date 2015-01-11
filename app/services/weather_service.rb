class WeatherService
  include HTTParty
  base_uri "https://weather.cit.cc.api.here.com"

  def self.for_lat_lng(lat, lng)
    response = get "/weather/1.0/report.json?app_id=#{ENV["HERE_APP_ID"]}&app_code=#{ENV["HERE_APP_CODE"]}&latitude=#{lat}&longitude=#{lng}&product=observation&oneobservation=true"

    if response.success?
      ob = response.parsed_response["observations"]["location"][0]["observation"][0]
      ob["temperature"]
    end
  end
end
