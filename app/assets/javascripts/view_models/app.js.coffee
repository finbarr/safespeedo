lazydefine "App", ["User", "Vehicle", "Speedo"], (User, Vehicle, Speedo) ->

  class App
    constructor: ->
      @user = ko.observable()
      @vehicle = ko.observable()
      @authorized = ko.computed =>
        !!@user()

    loadUser: (userId) ->
      return unless userId?
      return if @user()?
      bmw.get bmw.model("User"), {id: userId}, (error, result) =>
        if error
          console.log error
        else
          @user new User(result)

    loadVehicle: ->
      promise = $.Deferred()
      bmw.get bmw.model("Vehicle"), {}, (error, result) =>
        if error
          console.log error
          promise.reject()
        else
          cons = bmw.model("Vehicle")
          @vehicle new Vehicle(new cons(result.Data[0]))
          promise.resolve(@vehicle())
      promise
