#= require_tree ../templates

app = @WordBackpack
app.Views ?= {}

app.Views.SiteInformationView = Backbone.View.extend
  tagName: 'article'
  className: 'site-information-item slide-item on-center'

  render: (template) ->
    @$el.html(template())
    @el
