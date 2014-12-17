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
    return null if @first() == @currentCard
    @at(@currentIndex - 1)

  nextCard: ->
    return null if @last() == @currentCard
    @at(@currentIndex + 1)

  setCurrentCard: (card) ->
    @currentIndex = @indexOf(card)
    @currentCard = card

  destroyAfter: ->
    @rest(@currentIndex).each (card) ->
      card.destroy
