#= require_self
#= require_tree ./routers
#= require_tree ./models
#= require_tree ./views

'use strict'

@WordBackpack =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  init: ->
    new WordBackpack.Routers.WordRouter
    Backbone.history.start(pushState: true)

$ ->
  WordBackpack.init()
