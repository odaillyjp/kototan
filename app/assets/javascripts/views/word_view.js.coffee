#= require_tree ../templates

app = @Kototan
app.Views ?= {}

app.Views.WordView = Backbone.View.extend
  tagName: 'article'
  id: -> "word-#{@model.cid}"
  className: 'word-item slide-item on-center'
  template: JST['words/item']

  initialize: ->
    @listenTo @model, 'destroy', @remove
    @listenTo @model, 'change', @render

  render: ->
    context = @model.toJSON()
    @$el.html(@template(context))
    @el

app.Views.WordsView = Backbone.View.extend
  el: 'body'

  events:
    'click .kana-item-link': 'appendKana'
    'click .card-item-link': 'jumpToWord'
    'click .button-movable-left': 'moveToPrevWord'
    'click .button-movable-right': 'moveToNextWord'
    'click .button-clear-word': 'clearWord'
    'click .button-remove-word': 'removeWord'

  initialize: ->
    @wordsCollection = new app.Collections.WordsCollection()
    @listenTo @wordsCollection, 'add', @appendWord
    @listenTo @wordsCollection, 'change:currentIndex', @jumpToCurrentWord
    @cardsCollection = new app.Collections.CardsCollection()
    @listenTo @cardsCollection, 'add', @appendCard
    @listenTo @cardsCollection, 'change:currentIndex', @jumpToCurrentCard
    @render()
    @appendSiteInformation(JST['site_informations/title'])

  render: ->
    $(@$el).append(JST['words/index'])

  appendKana: (elem) ->
    currentKana = elem.currentTarget.dataset.kana
    card = new app.Models.Card(kana: currentKana)

    if @cardsCollection.isEmpty()
      @cardsCollection.add(card)
      @appendSiteInformation(JST['site_informations/first_kana'])
      return false

    @removeSiteInformation()
    @removeNotice()
    $('.tab-button-list', @$el).removeClass('is-hidden')
    previousKana = @cardsCollection.last().get('kana')

    @sendSearchRequest(previousKana, currentKana)
      .success (data) =>
        @cardsCollection.add(card)
        word = new app.Models.Word
          name: data.name
          furigana: data.furigana
          head: previousKana
          last: currentKana
        @wordsCollection.add(word)
      .error (xhr) =>
        errors = $.parseJSON(xhr.responseText).errors
        @appendNotice(errors)

    false

  sendSearchRequest: (head, last) ->
    $.ajax
      type: 'GET'
      url:  "/words/search?head=#{head}&last=#{last}"
      dataType: 'JSON'

  appendWord: (word) ->
    wordView = new app.Views.WordView(model: word)
    $('.slide-list', @$el).append(wordView.render())
    @wordsCollection.setCurrentWord(word)

  removeWord: ->
    if @wordsCollection.isLast()
      @wordsCollection.currentWord().destroy()
      @cardsCollection.currentCard().destroy()
      @wordsCollection.setCurrentWord(@wordsCollection.last())
      @cardsCollection.setCurrentCard(@cardsCollection.last())
    else
      prevWord = @wordsCollection.prevWord()
      nextWord = @wordsCollection.nextWord()
      prevCard = @cardsCollection.prevCard()
      nextCard = @cardsCollection.nextCard()
      @sendSearchRequest(prevCard.get('kana'), nextCard.get('kana'))
        .success (data) =>
          nextWord.set
            'name': data.name
            'furigana': data.furigana
            'head': prevCard.get('kana')
            'last': nextCard.get('kana')
          @wordsCollection.currentWord().destroy()
          @cardsCollection.currentCard().destroy()
          @wordsCollection.setCurrentWord(nextWord)
          @cardsCollection.setCurrentCard(nextCard)
        .error =>
          @wordsCollection.currentWord().destroy()
          @cardsCollection.currentCard().destroy()
          @wordsCollection.setCurrentWord(prevWord)
          @cardsCollection.setCurrentCard(prevCard)

  clearWord: ->
    @wordsCollection.reset()
    @cardsCollection.reset()
    @removeNotice()
    @changeMoveButtonState()
    $('.tab-button-list', @$el).addClass('is-hidden')
    $('.slide-list', @$el).html('')
    $('.card-list', @$el).html('')
    @appendSiteInformation(JST['site_informations/title'])

  appendCard: (card) ->
    cardView = new app.Views.CardView(model: card)
    $('.card-list', @$el).append(cardView.render())
    @cardsCollection.setCurrentCard(card)

  appendSiteInformation: (template) ->
    $('.site-information-item.on-center', @$el).removeClass('on-center').addClass('on-left-side is-opaqued')
    siteInformationView = new app.Views.SiteInformationView
    $('.slide-list', @$el).append(siteInformationView.render(template))

  removeSiteInformation: ->
    $('.site-information-item', @$el).remove()

  appendNotice: (message) ->
    message = message.join(' ') if _.isArray(message)
    $('.main-slideshow-area-inner', @$el).append("<div class='alert notice'>#{message}</div>")

  removeNotice: ->
    $('.alert.notice', @$el).remove()

  moveToPrevWord: ->
    @wordsCollection.setCurrentWord(@wordsCollection.prevWord())
    @cardsCollection.setCurrentCard(@cardsCollection.prevCard())

  moveToNextWord: ->
    @wordsCollection.setCurrentWord(@wordsCollection.nextWord())
    @cardsCollection.setCurrentCard(@cardsCollection.nextCard())

  jumpToWord: (elem) ->
    return false if @wordsCollection.isEmpty()
    destinationCard = $("##{elem.currentTarget.dataset.id}", @$el)
    destinationCardIndex = $('.card-item', @$el).index(destinationCard)
    destinationCardIndex = 1 if destinationCardIndex == 0
    return false if destinationCardIndex == @cardsCollection.currentIndex
    @cardsCollection.setCurrentCard(@cardsCollection.at(destinationCardIndex))
    @wordsCollection.setCurrentWord(@wordsCollection.at(destinationCardIndex - 1))

  jumpToCurrentWord: ->
    currentWord = $("#word-#{@wordsCollection.currentWord().cid}", @$el)
    currentWord.prevAll().removeClass('on-center on-right-side').addClass('on-left-side is-opaqued')
    currentWord.nextAll().removeClass('on-center on-left-side').addClass('on-right-side is-opaqued')
    currentWord.removeClass('on-right-side on-left-side is-opaqued').addClass('on-center')
    @changeMoveButtonState()

  jumpToCurrentCard: ->
    currentCard = $("#card-#{@cardsCollection.currentCard().cid}", @$el)
    $('.card-item.is-head', @$el).removeClass('is-head')
    $('.card-item.is-last', @$el).removeClass('is-last')
    currentCard.addClass('is-last')
    currentCard.prev().addClass('is-head')

  # ボタンの表示・非表示を切り替える
  changeMoveButtonState: ->
    # 戻るボタンの切り替え
    if @wordsCollection.isFirst() || @wordsCollection.isEmpty()
      $('.button-movable-left', @$el).addClass('is-hidden')
    else
      $('.button-movable-left', @$el).removeClass('is-hidden')
    # 進むボタンの切り替え
    if @wordsCollection.isLast() || @wordsCollection.isEmpty()
      $('.button-movable-right', @$el).addClass('is-hidden')
    else
      $('.button-movable-right', @$el).removeClass('is-hidden')
