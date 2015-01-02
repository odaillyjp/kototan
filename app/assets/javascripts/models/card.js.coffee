#= require ./indexable_collection

app = @Kototan
app.Models ?= {}
app.Collections ?= {}

app.Models.Card = Backbone.Model.extend {}

app.Collections.CardsCollection = app.Collections.IndexableCollection.extend
  model: app.Models.Card

  currentCard: -> @currentModel()
  prevCard: -> @prevModel()
  nextCard: -> @nextModel()
  setCurrentCard: (card) -> @setCurrentModel(card)
