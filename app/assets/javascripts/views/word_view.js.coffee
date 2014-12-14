#= require_tree ../templates

app = @WordBackpack
app.Views ?= {}

app.Views.WordView = Backbone.View.extend
  tagName: 'article'
  id: -> "word-#{@model.cid}"
  className: 'word-item slide-item on-center'
  template: JST['words/item']

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

  initialize: ->
    @wordsCollection = new app.Collections.WordsCollection()
    @wordsCollection.bind('add', @appendWord)
    @cardsCollection = new app.Collections.CardsCollection()
    @cardsCollection.bind('add', @appendCard)
    @render()
    @appendSiteInformation(JST['site_informations/title'])

  render: ->
    $(@$el).append(JST['words/index'])

  appendKana: (elem) ->
    currentKana = elem.currentTarget.dataset.kana
    card = new app.Models.Card(kana: currentKana)
    @cardsCollection.add(card)

    if @cardsCollection.length == 1
      @appendSiteInformation(JST['site_informations/first_kana'])
      return false

    @removeSiteInformation()
    @removeNotice()
    previousKana = @cardsCollection.at(@cardsCollection.length - 2).get('kana')
    @sendRequest(previousKana, currentKana)
    false

  sendRequest: (head, last) ->
    $.ajax
      type: 'GET'
      url:  "/words/search?head=#{head}&last=#{last}"
      dataType: 'JSON'
      success: (data) =>
        word = new app.Models.Word
          name: data.name
          furigana: data.furigana
          head: head
          last: last
        @wordsCollection.add(word)
      error: (xhr) =>
        errors = $.parseJSON(xhr.responseText).errors
        @appendNotice(errors)

  appendWord: (word) ->
    $('.word-item').removeClass('on-center on-right-side').addClass('on-left-side is-opaqued')
    $('.button-movable-right', @$el).addClass('is-hidden')
    wordView = new app.Views.WordView(model: word)
    $('.slide-list', @$el).append(wordView.render())
    $('.button-movable-left', @$el).removeClass('is-hidden') if $('.word-item', @$el).length >= 2

  appendCard: (card) ->
    $('.card-item.is-head', @$el).removeClass('is-head')
    $('.card-item.is-last', @$el).removeClass('is-last')
    cardView = new app.Views.CardView(model: card)
    $('.card-list', @$el).append(cardView.render())
    if $('.card-item', @$el).length >= 2
      $('.card-list', @$el).removeClass('is-hidden')
      $('.card-item:nth-last-child(3)', @$el).removeClass('is-head')
      $('.card-item:nth-last-child(2)', @$el).removeClass('is-last').addClass('is-head')
      $('.card-item:last-child', @$el).addClass('is-last')

  appendSiteInformation: (template) ->
    $('.site-information-item.on-center').removeClass('on-center').addClass('on-left-side is-opaqued')
    siteInformationView = new app.Views.SiteInformationView
    $('.slide-list', @$el).append(siteInformationView.render(template))

  removeSiteInformation: ->
    $('.site-information-item').remove()

  appendNotice: (message) ->
    message = message.join(' ') if _.isArray(message)
    $('.main-slideshow-area-inner', @$el).append("<div class='alert notice'>#{message}</div>")

  removeNotice: ->
    $('.alert.notice', @$el).remove()

  moveToPrevWord: ->
    currentWord = $('.word-item.on-center')
    currentHeadCard = $('.card-item.is-head')
    currentWord.removeClass('on-center').addClass('on-right-side is-opaqued')
    currentWord.prev().removeClass('on-left-side is-opaqued').addClass('on-center')
    currentHeadCard.prev().addClass('is-head')
    currentHeadCard.removeClass('is-head').addClass('is-last')
    currentHeadCard.next().removeClass('is-last')
    $('.button-movable-right', @$el).removeClass('is-hidden')
    $('.button-movable-left', @$el).addClass('is-hidden') if currentWord.prevAll().length <= 1

  moveToNextWord: ->
    currentWord = $('.word-item.on-center')
    currentLastCard = $('.card-item.is-last')
    currentWord.removeClass('on-center').addClass('on-left-side is-opaqued')
    currentWord.next().removeClass('on-right-side is-opaqued').addClass('on-center')
    currentLastCard.next().addClass('is-last')
    currentLastCard.removeClass('is-last').addClass('is-head')
    currentLastCard.prev().removeClass('is-head')
    $('.button-movable-left', @$el).removeClass('is-hidden')
    $('.button-movable-right', @$el).addClass('is-hidden') if currentWord.nextAll().length <= 1

  jumpToWord: (elem) ->
    destinationCard = $("##{elem.currentTarget.dataset.id}", @$el)
    currentCard = $('.card-item.is-head', @$el)
    return false if destinationCard == currentCard
    destinationIndex = $('.card-item', @$el).index(destinationCard)
    currentIndex = $('.card-item', @$el).index(currentCard)
    destinationWord = $(".word-item:nth-child(#{destinationIndex})", @$el)
    # ことばのクラスを更新
    if destinationIndex > currentIndex
      $(".word-item:not(:nth-child(n+#{destinationIndex}))").removeClass('on-center on-right-side').addClass('on-left-side is-opaqued')
    else
      $(".word-item:nth-child(n+#{destinationIndex + 1})").removeClass('on-center on-left-side').addClass('on-right-side is-opaqued')
    destinationWord.removeClass('on-right-side on-left-side is-opaqued').addClass('on-center')
    # カードのクラスを更新
    $('.card-item.is-head', @$el).removeClass('is-head')
    $('.card-item.is-last', @$el).removeClass('is-last')
    destinationCard.addClass('is-last')
    destinationCard.prev().addClass('is-head')
    # ボタンの状態を更新
    if destinationWord.prevAll().length <= 1
      $('.button-movable-left', @$el).addClass('is-hidden')
    else
      $('.button-movable-left', @$el).removeClass('is-hidden')
    if destinationWord.nextAll().length <= 1
      $('.button-movable-right', @$el).addClass('is-hidden') 
    else
      $('.button-movable-right', @$el).removeClass('is-hidden') 
