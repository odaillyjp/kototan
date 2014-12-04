app = @WordBackpack
app.Models ?= {}
app.Collections ?= {}

app.Models.Word = Backbone.Model.extend
  defaults:
    name: ''
    furigana: ''
    head: ''
    last: ''

app.Collections.WordsCollection = Backbone.Collection.extend
  model: app.Models.Word
