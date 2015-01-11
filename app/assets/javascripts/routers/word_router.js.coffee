app = @Kototan
app.Routers ?= {}

app.Routers.WordRouter = Backbone.Router.extend
  routes:
    '.*' : 'index'

  index: ->
    new app.Views.WordSlidesView
