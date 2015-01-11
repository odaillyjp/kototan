#= require_tree ../templates

app = @Kototan
app.Views ?= {}

app.Views.InformationSlideView = Backbone.View.extend
  tagName: 'article'
  className: 'information-item slide-item on-center'

  render: (template) ->
    @$el.html(template())
    @el
