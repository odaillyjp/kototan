class WordsController < ApplicationController
  def index
    @kana_list = Kana.all
  end

  def search
    word = WordBasket::Word.sample(head: params[:head], last: params[:last])
    render json: { name: word.name, furigana: word.furigana }
  end
end
