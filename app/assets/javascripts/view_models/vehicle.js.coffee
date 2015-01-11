lazydefine "Vehicle", ["Speedo"], (Speedo) ->

  class Vehicle
    constructor: (result) ->
      @lat = ko.observable(result.LastLocation.Lat)
      @lng = ko.observable(result.LastLocation.Lng)
      @speedo = new Speedo()
      @location = ko.observable()

      @updatingSpeedLimit = ko.observable false
      @needSpeedLimitUpdate = ko.observable false
      @updatingWeather = ko.observable false
      @needWeatherUpdate = ko.observable false

      @locationUpdated()

      change = (entity) =>
        updated = false
        if entity.LastLocation.Lat?
          @lat entity.LastLocation.Lat
          updated = true

        if entity.LastLocation.Lng?
          @lng entity.LastLocation.Lng
          updated = true

        @locationUpdated() if updated

        if entity.LastRpm?
          # hijacking this to simulate rain intensity
          @speedo.rainIntensity entity.LastRpm

        if entity.LastSpeed?
          @speedo.currentSpeed entity.LastSpeed

      callback = (error, result) ->
        if error
          console.log error
        else
          console.log result

      bmw.observe result, null, change, callback

    locationUpdated: ->
      @location.notifySubscribers()
      @checkForBlackspot()
      @updateSpeedLimit()
      @updateWeather()

    updateSpeedLimit: ->
      return if @updatingSpeedLimit()
      @updatingSpeedLimit true
      $.getJSON "/speed_limit?lat=#{@lat()}&lng=#{@lng()}", (data) =>
        if data.speed_limit? && data.speed_limit > 0
          @speedo.speedLimit data.speed_limit
        @updatingSpeedLimit false

    updateWeather: ->
      return if @updatingWeather()
      @updatingWeather true
      $.getJSON "/weather?lat=#{@lat()}&lng=#{@lng()}", (data) =>
        if data.temp?
          @speedo.temp data.temp
        @updatingWeather false

    checkForBlackspot: ->
      $.getJSON "/blackspots/near?lat=#{@lat()}&lng=#{@lng()}", (data) =>
        @speedo.nearBlackspot !!data.bs
