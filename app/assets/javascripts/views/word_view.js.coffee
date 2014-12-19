#= require_tree ../templates

app = @WordBackpack
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
    'click .button-remove-word': 'removeWord'

  initialize: ->
    @wordsCollection = new app.Collections.WordsCollection()
    @listenTo @wordsCollection, 'add', @appendWord
    @cardsCollection = new app.Collections.CardsCollection()
    @listenTo @cardsCollection, 'add', @appendCard
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
    $('.word-item', @$el).removeClass('on-center on-right-side').addClass('on-left-side is-opaqued')
    $('.button-movable-right', @$el).addClass('is-hidden')
    wordView = new app.Views.WordView(model: word)
    $('.slide-list', @$el).append(wordView.render())
    $('.button-remove-word', @$el).removeClass('is-hidden')
    $('.button-movable-left', @$el).removeClass('is-hidden') if $('.word-item', @$el).length >= 2

  removeWord: ->
    styleSetting = =>
      @resetCardClass()
      $("#word-#{@wordsCollection.currentWord.cid}", @$el).removeClass('on-left-side on-right-side is-opaqued').addClass('on-center')
      $("#card-#{@cardsCollection.currentCard.cid}", @$el).addClass('is-last')
      $("#card-#{@cardsCollection.prevCard().cid}", @$el).addClass('is-head')
      @changeMoveButtonState()
    if @wordsCollection.isLast()
      @wordsCollection.currentWord.destroy()
      @cardsCollection.currentCard.destroy()
      @wordsCollection.setCurrentWord(@wordsCollection.last())
      @cardsCollection.setCurrentCard(@cardsCollection.last())
      styleSetting()
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
          @wordsCollection.currentWord.destroy()
          @cardsCollection.currentCard.destroy()
          @wordsCollection.setCurrentWord(nextWord)
          @cardsCollection.setCurrentCard(nextCard)
          styleSetting()
        .error =>
          @wordsCollection.currentWord.destroy()
          @cardsCollection.currentCard.destroy()
          @wordsCollection.setCurrentWord(prevWord)
          @cardsCollection.setCurrentCard(prevCard)
          styleSetting()

  appendCard: (card) ->
    @resetCardClass()
    cardView = new app.Views.CardView(model: card)
    $('.card-list', @$el).append(cardView.render())
    if $('.card-item', @$el).length >= 2
      $('.card-list', @$el).removeClass('is-hidden')
      $('.card-item:nth-last-child(3)', @$el).removeClass('is-head')
      $('.card-item:nth-last-child(2)', @$el).removeClass('is-last').addClass('is-head')
      $('.card-item:last-child', @$el).addClass('is-last')

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
    currentWord = $("#word-#{@wordsCollection.currentWord.cid}", @$el)
    currentHeadCard = $("#card-#{@cardsCollection.prevCard().cid}", @$el)
    # ことばをスライドさせる
    currentWord.prev().removeClass('on-left-side is-opaqued').addClass('on-center')
    currentWord.removeClass('on-center').addClass('on-right-side is-opaqued')
    # ひらがなカードをスライドさせる
    currentHeadCard.prev().addClass('is-head')
    currentHeadCard.removeClass('is-head').addClass('is-last')
    currentHeadCard.next().removeClass('is-last')
    # Collectionオブジェクトに表示位置を覚えさせる
    @wordsCollection.setCurrentWord(@wordsCollection.prevWord())
    @cardsCollection.setCurrentCard(@cardsCollection.prevCard())
    @changeMoveButtonState()

  moveToNextWord: ->
    currentWord = $("#word-#{@wordsCollection.currentWord.cid}", @$el)
    currentLastCard = $("#card-#{@cardsCollection.currentCard.cid}", @$el)
    # ことばをスライドさせる
    currentWord.removeClass('on-center').addClass('on-left-side is-opaqued')
    currentWord.next().removeClass('on-right-side is-opaqued').addClass('on-center')
    # ひらがなカードをスライドさせる
    currentLastCard.next().addClass('is-last')
    currentLastCard.removeClass('is-last').addClass('is-head')
    currentLastCard.prev().removeClass('is-head')
    # Collectionオブジェクトに表示位置を覚えさせる
    @wordsCollection.setCurrentWord(@wordsCollection.nextWord())
    @cardsCollection.setCurrentCard(@cardsCollection.nextCard())
    @changeMoveButtonState()

  jumpToWord: (elem) ->
    destinationCard = $("##{elem.currentTarget.dataset.id}", @$el)
    currentCard = $("#card-#{@cardsCollection.currentCard.cid}", @$el)
    return false if destinationCard == currentCard
    destinationCardIndex = $('.card-item', @$el).index(destinationCard)
    destinationWord = $(".word-item:nth-child(#{destinationCardIndex})", @$el)
    # ことばのクラスを更新
    if destinationCardIndex > @cardsCollection.currentIndex
      # 移動先のことばより前のことばを、左にスライドさせる
      $(".word-item:not(:nth-child(n+#{destinationCardIndex}))", @$el).removeClass('on-center on-right-side').addClass('on-left-side is-opaqued')
    else
      # 移動先のことばより後のことばを、右にスライドさせる
      $(".word-item:nth-child(n+#{destinationCardIndex + 1})", @$el).removeClass('on-center on-left-side').addClass('on-right-side is-opaqued')
    destinationWord.removeClass('on-right-side on-left-side is-opaqued').addClass('on-center')
    @wordsCollection.setCurrentWord(@wordsCollection.at(destinationCardIndex - 1))
    # カードのクラスを更新
    @resetCardClass()
    destinationCard.addClass('is-last')
    destinationCard.prev().addClass('is-head')
    @cardsCollection.setCurrentCard(@cardsCollection.at(destinationCardIndex))
    @changeMoveButtonState()

  # ボタンの表示・非表示を切り替える
  changeMoveButtonState: ->
    # 戻るボタンの切り替え
    if @cardsCollection.isFirst() || @wordsCollection.isFirst()
      $('.button-movable-left', @$el).addClass('is-hidden')
    else
      $('.button-movable-left', @$el).removeClass('is-hidden')
    # 進むボタンの切り替え
    if @cardsCollection.isFirst() || @wordsCollection.isLast()
      $('.button-movable-right', @$el).addClass('is-hidden')
    else
      $('.button-movable-right', @$el).removeClass('is-hidden')

  # ひらがなカードのクラスのリセット
  resetCardClass: ->
    $('.card-item.is-head', @$el).removeClass('is-head')
    $('.card-item.is-last', @$el).removeClass('is-last')
