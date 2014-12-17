app = @WordBackpack
app.Models ?= {}
app.Collections ?= {}

app.Models.Word = Backbone.Model.extend {}

app.Collections.WordsCollection = Backbone.Collection.extend
  model: app.Models.Word
  currentIndex: -1
  currentWord: null

  initialize: ->
    @listenTo @, 'add', @setCurrentWord

  prevWord: ->
    return null if @isFirst()
    @at(@currentIndex - 1)

  nextWord: ->
    return null if @isLast()
    @at(@currentIndex + 1)

  setCurrentWord: (word) ->
    @currentIndex = @indexOf(word)
    @currentWord = word

  isFirst: ->
    @first() == @currentWord

  isLast: ->
    @last() == @currentWord

  destroyAfter: ->
    @rest(@currentIndex).each (word) ->
      word.destroy
