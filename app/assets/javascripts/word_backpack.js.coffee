#= require_self
#= require_tree ./routers
#= require_tree ./models
#= require_tree ./views

'use strict'

@Kototan =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  init: ->
    new Kototan.Routers.WordRouter
    Backbone.history.start(pushState: true)

$ ->
  Kototan.init()

# hack for Turbolinks
$(document).on "page:load", ->
  Backbone.history.loadUrl()
