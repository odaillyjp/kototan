app = @Kototan
app.Collections ?= {}

app.Collections.IndexableCollection = Backbone.Collection.extend
  currentIndex: -1

  initialize: ->
    @listenTo @, 'reset', @resetIndex

  resetIndex: ->
    @currentIndex = -1

  currentModel: ->
    @at(@currentIndex)

  prevModel: ->
    return null if @isFirst()
    @at(@currentIndex - 1)

  nextModel: ->
    return null if @isLast()
    @at(@currentIndex + 1)

  setCurrentModel: (model) ->
    beforeCurrentIndex = @currentIndex
    @currentIndex = @indexOf(model)
    @.trigger('change:currentIndex')

  isFirst: ->
    @first() == @currentModel()

  isLast: ->
    @last() == @currentModel()
