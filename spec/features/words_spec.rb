require 'rails_helper'

feature 'Word', type: :feature, js: true do
  background do
    WordBasket::Word.create('紫陽花', 'あじさい')
    WordBasket::Word.create('イチゴ牛乳', 'いちごぎゅうにゅう')
    WordBasket::Word.create('浮世絵', 'うきよえ')
    WordBasket::Word.create('笑顔', 'えがお')
    visit root_path
  end

  feature '存在する言葉を検索する' do
    background do
      within('.main-kana') do
        click_link 'あ'
        click_link 'い'
      end
    end

    scenario '言葉が表示されること' do
      within('.slide-item.on-center') do
        expect(page.find('.word-slide-item-name')).to have_content('紫陽花')
        expect(page.find('.word-slide-item-furigana')).to have_content('あじさい')
      end
    end

    feature '最初からやり直す' do
      background do
        within('.tab-button-list') do
          click_link '最初からやり直す'
        end
      end

      scenario 'タイトルが表示されること' do
        within('.slide-item.on-center') do
          expect(page.find('.information-title')).to have_content('ことばの探索機')
        end
      end
    end
  end

  feature '存在しない言葉を検索する' do
    background do
      within('.main-kana') do
        click_link 'あ'
        click_link 'お'
      end
    end

    scenario '警告メッセージが表示されること' do
      expect(page.find('.notice')).to have_content('単語が見つかりませんでした。')
    end
  end

  feature '存在する言葉を連続で検索する' do
    background do
      click_link 'あ'
      click_link 'い'
      click_link 'う'
      click_link 'え'
      click_link 'お'
    end

    scenario '最後の選択した文字を使った言葉が中央に表示されること' do
      within('.slide-item.on-center') do
        expect(page.find('.word-slide-item-name')).to have_content('笑顔')
        expect(page.find('.word-slide-item-furigana')).to have_content('えがお')
      end
    end

    scenario '最後以外の言葉は左側表示となっていること' do
      within('.slide-list') do
        # TODO: class を持っているかを調べる matcher を作る
        expect(page.all('.word-slide-item')[0].native['class'].split(/\s/)).to be_include 'on-left-side'
        expect(page.all('.word-slide-item')[1].native['class'].split(/\s/)).to be_include 'on-left-side'
        expect(page.all('.word-slide-item')[2].native['class'].split(/\s/)).to be_include 'on-left-side'
      end
    end

    scenario '最後以外の言葉は非表示となっていること' do
      within('.slide-list') do
        # TODO: class を持っているかを調べる matcher を作る
        expect(page.all('.word-slide-item')[0].native['class'].split(/\s/)).to be_include 'is-opaqued'
        expect(page.all('.word-slide-item')[1].native['class'].split(/\s/)).to be_include 'is-opaqued'
        expect(page.all('.word-slide-item')[2].native['class'].split(/\s/)).to be_include 'is-opaqued'
      end
    end

    feature '最初に表示された言葉を見る' do
      background do
        within('.card-list') do
          click_link 'あ'
        end
      end

      scenario '最初の言葉が中央に表示されること' do
        within('.slide-item.on-center') do
          expect(page.find('.word-slide-item-name')).to have_content('紫陽花')
          expect(page.find('.word-slide-item-furigana')).to have_content('あじさい')
        end
      end

      scenario '最後以外の言葉は右側表示となっていること' do
        within('.slide-list') do
          # TODO: class を持っているかを調べる matcher を作る
          expect(page.all('.word-slide-item')[1].native['class'].split(/\s/)).to be_include 'on-right-side'
          expect(page.all('.word-slide-item')[2].native['class'].split(/\s/)).to be_include 'on-right-side'
          expect(page.all('.word-slide-item')[3].native['class'].split(/\s/)).to be_include 'on-right-side'
        end
      end

      scenario '最後以外の言葉は非表示となっていること' do
        within('.slide-list') do
          # TODO: class を持っているかを調べる matcher を作る
          expect(page.all('.word-slide-item')[1].native['class'].split(/\s/)).to be_include 'is-opaqued'
          expect(page.all('.word-slide-item')[2].native['class'].split(/\s/)).to be_include 'is-opaqued'
          expect(page.all('.word-slide-item')[3].native['class'].split(/\s/)).to be_include 'is-opaqued'
        end
      end
    end
  end
end
