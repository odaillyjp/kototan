# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.selectMoji', ->
  selectChar = $(@).text()

  if $('#selectedArea .firstMoji').text() == ''
    $('#selectedArea .firstMoji').append("場のカード <span class='moji'>#{selectChar}</span>")
    $('section .notice').text('あなたが持っている文字をクリック')
  else
    currentChar = $('#selectedArea .moji:last').text()
    word = null
    furigana = null
    $.ajax({
      type: "GET",
      url:  "/words/search?head=#{currentChar}&last=#{selectChar}",
      dataType: "JSON",
      success: (data) ->
        word = data.name
        furigana = data.furigana
        $('#selectedArea .words').append("<div><span class='moji'>#{selectChar}</span> #{furigana} #{word}</div>")
    })
