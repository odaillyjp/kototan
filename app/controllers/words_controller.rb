class WordsController < ApplicationController
  def index
  end

  def search
    word = WordBasket::Word.sample(head: params[:head], last: params[:last])

    if word.present?
      render json: { name: word.name, furigana: word.furigana }
    else
      render json: { errors: %w(単語が見つかりませんでした。) }, status: 400
    end
  end
end
