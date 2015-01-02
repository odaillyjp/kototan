#= require ./indexable_collection

app = @Kototan
app.Models ?= {}
app.Collections ?= {}

app.Models.Word = Backbone.Model.extend {}

app.Collections.WordsCollection = app.Collections.IndexableCollection.extend
  model: app.Models.Word

  currentWord: -> @currentModel()
  prevWord: -> @prevModel()
  nextWord: -> @nextModel()
  setCurrentWord: (word) -> @setCurrentModel(word)
