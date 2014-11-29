using WordBasket::StringExtension

module WordBasket
  class Word
    attr_reader :name, :furigana, :head, :last

    # class methods

    def self.create(name, furigana = nil)
      word = Word.new(name, furigana)
      word.save
      word
    end

    def self.sample(query)
      word = WordBasket.configuration.database.sample(OpenStruct.new(query))
      Word.new(word[:name], word[:furigana]) if word
    end

    # instance methods

    def initialize(name, furigana = nil)
      # 振り仮名がNullで、かつ単語名に「ひらがな」「カタカナ」以外が含まれている場合は例外発生
      fail '「振り仮名」が登録されていません。' if furigana.nil? && !name.hira_or_kata_only?
      # 振り仮名に「ひらがな」以外が含まれている場合は例外発生
      fail '「振り仮名」にひらがな以外の文字が含まれています。' if furigana.present? && !furigana.hira_only?

      @name     = name
      @furigana = furigana || name.convert_kata_to_hira
      @head     = @furigana[0].convert_dakuten_to_seion

      # 最終文字の判定
      @last     = if Moji.type?(@furigana[-1], Moji::ZEN_JSYMBOL)
        # 最後の文字が長音のときは、脚韻を抽出する
        @furigana[-2].convert_sutegana_to_seion
          .convert_dakuten_to_seion
          .convert_to_boin
      else
        # それ以外のときは、静音を抽出する
        @furigana[-1].convert_sutegana_to_seion
          .convert_dakuten_to_seion
      end
    end

    def save
      WordBasket.configuration.database.set(self)
    end
  end
end
