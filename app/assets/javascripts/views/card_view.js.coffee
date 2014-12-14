#= require_tree ../templates

app = @WordBackpack
app.Views ?= {}

app.Views.CardView = Backbone.View.extend
  tagName: 'article'
  className: 'card-item'
  template: JST['cards/item']

  render: ->
    content = @model.toJSON()
    @$el.html(@template(content))
    @el
