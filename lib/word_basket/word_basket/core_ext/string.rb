module WordBasket
  module StringExtension
    refine String do
      # 「ひらがな」「カタカナ」だけで構成されていればtrueを返す
      # 注意: 長音符などの記号が含まれていてもtrueを返す
      def hira_or_kata_only?
        self.chars.all? { |char| Moji.type?(char, Moji::ZEN_HIRA | Moji::ZEN_KATA | Moji::ZEN_JSYMBOL) }
      end

      # 「ひらがな」だけで構成されていればtrueを返す
      # 注意: 長音符などの記号が含まれていてもtrueを返す
      def hira_only?
        self.chars.all? { |char| Moji.type?(char, Moji::ZEN_HIRA | Moji::ZEN_JSYMBOL) }
      end

      # 濁点や半濁点を清音に変換する
      def convert_dakuten_to_seion
        self.chars.map { |char| char.to_nfd.split('').first }.join
      end

      # 「カタカナ」を「ひらがな」に変換する
      def convert_kata_to_hira
        Moji.kata_to_hira(self)
      end

      # 捨て仮名を清音に変換する
      # 注意: 「カタカナ」は未対応
      def convert_sutegana_to_seion
        syllables = {
          sutegana: 'ぁぃぅぇぉっゃゅょゎ',
          seion:    'あいうえおつやゆよわ'
        }

        self.tr(syllables[:sutegana], syllables[:seion])
      end

      # 母音に変換する
      # 注意: 「カタカナ」は未対応
      def convert_to_boin
        char_maps = {
          %w(あ か さ た な は ま や ら わ) => 'あ',
          %w(い き し ち に ひ み    り   ) => 'い',
          %w(う く す つ ぬ ふ む ゆ る   ) => 'う',
          %w(え け せ て ね へ め    れ   ) => 'え',
          %w(お こ そ と の ほ も よ ろ   ) => 'お'
        }

        str = self

        char_maps.each do |chars, boin|
          str = str.gsub(/[#{chars.join}]/, boin)
        end

        str
      end
    end
  end
end
