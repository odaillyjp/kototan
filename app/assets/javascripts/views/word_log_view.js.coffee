#= require_tree ../templates

app = @Kototan
app.Views ?= {}

app.Views.WordLogView = Backbone.View.extend
  tagName: 'article'
  id: -> "word-log-#{@model.cid}"
  className: 'word-log-item'
  template: JST['word_logs/item']

  render: ->
    context = @model.toJSON()
    @$el.html(@template(context))
    @el

app.Views.WordLogsView = Backbone.View.extend
  className: 'word-log-modal modal'
  template: JST['word_logs/index']

  events:
    'click .modal-button-close': 'remove'
    'click .overlay': 'remove'

  render: ->
    @$el.html(@template())
    @collection.each (word) =>
      wordLogView = new app.Views.WordLogView(model: word)
      $('.word-log-list', @$el).append(wordLogView.render())
    @el
