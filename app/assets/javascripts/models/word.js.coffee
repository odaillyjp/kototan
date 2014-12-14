app = @WordBackpack
app.Models ?= {}
app.Collections ?= {}

app.Models.Word = Backbone.Model.extend {}

app.Collections.WordsCollection = Backbone.Collection.extend
  model: app.Models.Word
