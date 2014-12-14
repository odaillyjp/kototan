app = @WordBackpack
app.Models ?= {}
app.Collections ?= {}

app.Models.Card = Backbone.Model.extend {}

app.Collections.CardsCollection = Backbone.Collection.extend
  model: app.Models.Card
