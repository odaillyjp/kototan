#= require_tree ../templates

app = @WordBackpack
app.Views ?= {}

app.Views.WordView = Backbone.View.extend
  tagName: 'article'
  className: 'main-word-item'

  render: ->
    $(@el).append(JST['words/item'](@model.toJSON()))
    @el

app.Views.WordsView = Backbone.View.extend
  el: 'body'

  events:
    'click .main-kana-item': 'appendKana'

  initialize: ->
    @collection = new app.Collections.WordsCollection()
    @collection.bind('add', @appendWord)
    @kanaLists = []
    @render()

  render: ->
    $(@$el).append(JST['words/index'])

  appendKana: (elem) ->
    currentKana = elem.currentTarget.dataset.kana
    @kanaLists.push(currentKana)

    return false if @kanaLists.length < 2

    previousKana = @kanaLists[@kanaLists.length - 2]
    @sendRequest(previousKana, currentKana)
    false

  sendRequest: (head, last) ->
    $.ajax(
      type: 'GET',
      url:  "/words/search?head=#{head}&last=#{last}",
      dataType: 'JSON'
    ).done (data) =>
      word = new app.Models.Word
        name: data.name
        furigana: data.furigana
        head: head
        last: last
      @collection.add(word)

  appendWord: (word) ->
    wordView = new app.Views.WordView({ model: word })
    $('.main-word-list', @$el).append(wordView.render())

$ ->
  new app.Views.WordsView()
