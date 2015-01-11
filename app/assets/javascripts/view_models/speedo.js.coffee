lazydefine "Speedo", ->

  class Speedo
    constructor: ->
      @gauge = new Gauge
        renderTo: 'gauge'
        animation:
          delay: 0
          duration: 250
          fn: "quad"
        units: "mph"
        strokeTicks: false
        glow: false
        majorTicks: [0, '', 20, '', 40, '', 60, '', 80, '', 100, '', 120, '', 140]
        minorTicks: 2
        width: 531
        height: 531
        minValue: 0
        maxValue: 140
        colors:
          plate: '#383834',
          majorTicks: '#E3E3E3',
          minorTicks: '#E3E3E3',
          title: '#E3E3E3',
          units: '#E3E3E3',
          numbers: '#E3E3E3'

      @nearBlackspot = ko.observable(false)
      @temp = ko.observable(0)
      @rainIntensity = ko.observable(0)

      @warningBadgeUrl = ko.computed =>
        if @temp() && @temp() < 0
          "assets/ice.png"
        else if @rainIntensity() > 60
          "assets/rain.png"
        else if @nearBlackspot()
          "assets/crash.png"

      @currentSpeed = ko.observable(0)
      @currentSpeed.subscribe (s) =>
        @updateGauge()

      @speedLimit = ko.observable(0)
      @speedLimit.subscribe (s) =>
        @updateGauge()

      @advisorySpeed = ko.computed =>
        mod = 1.0

        if @nearBlackspot()
          mod -= 0.2

        if @temp() && @temp() < 0
          mod -= 0.2

        if @rainIntensity() && @rainIntensity() > 60
          mod -= 0.15

        @speedLimit() * mod

      @advisorySpeed.subscribe (s) =>
        @updateGauge()

      @needleColor = ko.computed =>
        if @currentSpeed() <= @advisorySpeed()
          "#30D606"
        else if @currentSpeed() <= @speedLimit()
          "#FFB236"
        else
          "#FF0011"

      @updateGauge()
      @updateNeedle(@needleColor())
      @gauge.draw()

      @needleColor.subscribe (color) =>
        @updateNeedle(color)

    updateNeedle: (color) ->
      @gauge.updateConfig({
        colors: {
          needle: { start: color, end: color }
        }
      })

    updateGauge: ->
      @gauge.setValue @currentSpeed()
      @gauge.updateConfig({
        highlights: [
          {from: 0, to: @advisorySpeed(), color: '#34AD58'},
          {from: @advisorySpeed(), to: @speedLimit(), color: '#D4A135'},
          {from: @speedLimit(), to: 140, color: '#ED4550'}
        ]
      })
