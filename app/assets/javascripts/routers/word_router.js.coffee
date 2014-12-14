app = @WordBackpack
app.Routers ?= {}

app.Routers.WordRouter = Backbone.Router.extend
  routes:
    '.*' : 'index'

  index: ->
    new app.Views.WordsView
