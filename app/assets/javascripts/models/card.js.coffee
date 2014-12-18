app = @WordBackpack
app.Models ?= {}
app.Collections ?= {}

app.Models.Card = Backbone.Model.extend {}

app.Collections.CardsCollection = Backbone.Collection.extend
  model: app.Models.Card
  currentIndex: -1
  currentCard: null

  initialize: ->
    @listenTo @, 'add', @setCurrentCard

  prevCard: ->
    return null if @isFirst()
    @at(@currentIndex - 1)

  nextCard: ->
    return null if @isLast()
    @at(@currentIndex + 1)

  setCurrentCard: (card) ->
    @currentIndex = @indexOf(card)
    @currentCard = card

  isFirst: ->
    @first() == @currentCard

  isLast: ->
    @last() == @currentCard

  destroyAfterCurrent: ->
    _.each @rest(@currentIndex).reverse(), (card) ->
      card.destroy()
    @setCurrentCard(@last())
