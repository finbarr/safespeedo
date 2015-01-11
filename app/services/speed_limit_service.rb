class SpeedLimitService
  include HTTParty
  base_uri "http://route.st.nlp.nokia.com"

  def self.for_lat_lng(lat, lng)
    response = get "/routing/6.2/getlinkinfo.json?app_id=#{ENV["HERE_APP_ID"]}&app_code=#{ENV["HERE_APP_CODE"]}&waypoint=#{lat},#{lng}"

    if response.success?
      ((response.parsed_response["Response"]["Link"][0]["SpeedLimit"].to_i * 2.23694) / 5.0).ceil * 5
    end
  end
end
