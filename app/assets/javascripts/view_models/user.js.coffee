lazydefine "User", ->

  class User
    constructor: (result) ->
      @firstName = ko.observable(result.FirstName)
      @lastName = ko.observable(result.LastName)
      @userName = ko.observable(result.UserName)
      @email = ko.observable(result.Email)
