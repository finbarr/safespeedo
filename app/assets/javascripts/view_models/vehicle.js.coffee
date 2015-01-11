lazydefine "Vehicle", ["Speedo"], (Speedo) ->

  class Vehicle
    constructor: (result) ->
      @lat = ko.observable(result.LastLocation.Lat)
      @lng = ko.observable(result.LastLocation.Lng)
      @speedo = new Speedo()
      @locationUpdated()

      @updatingWeather = ko.observable false
      @updatingSpeedLimit = ko.observable false

      change = (entity) =>
        updated = false
        if entity.LastLocation.Lat?
          @lat entity.LastLocation.Lat
          updated = true

        if entity.LastLocation.Lng?
          @lng entity.LastLocation.Lng
          updated = true

        @locationUpdated() if updated

        console.log entity

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
      @checkForBlackspot()
      @updateSpeedLimit()
      @updateWeather()

    updateSpeedLimit: ->
      $.getJSON "/speed_limit?lat=#{@lat()}&lng=#{@lng()}", (data) =>
        if data.speed_limit? && data.speed_limit > 0
          @speedo.speedLimit data.speed_limit

    updateWeather: ->
      $.getJSON "/weather?lat=#{@lat()}&lng=#{@lng()}", (data) =>
        if data.temp?
          @speedo.temp data.temp

    checkForBlackspot: ->
      $.getJSON "/blackspots/near?lat=#{@lat()}&lng=#{@lng()}", (data) =>
        @speedo.nearBlackspot !!data.bs
