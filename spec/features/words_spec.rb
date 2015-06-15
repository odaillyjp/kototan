require 'rails_helper'

feature 'Word', type: :feature, js: true do
  background do
    WordBasket::Word.create('紫陽花', 'あじさい')
    WordBasket::Word.create('イチゴ牛乳', 'いちごぎゅうにゅう')
    WordBasket::Word.create('浮世絵', 'うきよえ')
    WordBasket::Word.create('笑顔', 'えがお')
    WordBasket::Word.create('言い伝え', 'いいつたえ')
    visit root_path
  end

  feature '存在する言葉を検索する' do
    background do
      within('.main-kana') do
        click_link 'あ'
        wait_for_ajax
        click_link 'い'
        wait_for_ajax
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
          wait_for_ajax
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
        wait_for_ajax
        click_link 'お'
        wait_for_ajax
      end
    end

    scenario '警告メッセージが表示されること' do
      expect(page.find('.notice')).to have_content('単語が見つかりませんでした。')
    end
  end

  feature '存在する言葉を連続で検索する' do
    background do
      click_link 'あ'
      wait_for_ajax
      click_link 'い'
      wait_for_ajax
      click_link 'う'
      wait_for_ajax
      click_link 'え'
      wait_for_ajax
      click_link 'お'
      wait_for_ajax
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
        expect(page.all('.word-slide-item')[0]).to have_class 'on-left-side'
        expect(page.all('.word-slide-item')[1]).to have_class 'on-left-side'
        expect(page.all('.word-slide-item')[2]).to have_class 'on-left-side'
      end
    end

    scenario '最後以外の言葉は非表示となっていること' do
      within('.slide-list') do
        # TODO: class を持っているかを調べる matcher を作る
        expect(page.all('.word-slide-item')[0]).to have_class 'is-opaqued'
        expect(page.all('.word-slide-item')[1]).to have_class 'is-opaqued'
        expect(page.all('.word-slide-item')[2]).to have_class 'is-opaqued'
      end
    end

    feature '最初に表示された言葉を見る' do
      background do
        within('.card-list') do
          click_link 'あ'
          wait_for_ajax
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
          expect(page.all('.word-slide-item')[1]).to have_class 'on-right-side'
          expect(page.all('.word-slide-item')[2]).to have_class 'on-right-side'
          expect(page.all('.word-slide-item')[3]).to have_class 'on-right-side'
        end
      end

      scenario '最後以外の言葉は非表示となっていること' do
        within('.slide-list') do
          expect(page.all('.word-slide-item')[1]).to have_class 'is-opaqued'
          expect(page.all('.word-slide-item')[2]).to have_class 'is-opaqued'
          expect(page.all('.word-slide-item')[3]).to have_class 'is-opaqued'
        end
      end
    end

    feature '最後の言葉を取り除く' do
      background do
        within('.tab-button-list') do
          click_link 'ことばを取り除く'
          wait_for_ajax
        end
      end

      scenario '最後から一つ前の言葉が中央に表示されること' do
        within('.slide-item.on-center') do
          expect(page.find('.word-slide-item-name')).to have_content('浮世絵')
          expect(page.find('.word-slide-item-furigana')).to have_content('うきよえ')
        end
      end

      scenario '最後の言葉がページから無くなっていること' do
        within('.slide-item.on-center') do
          expect(page).to have_no_content('笑顔')
          expect(page).to have_no_content('えがお')
        end
      end
    end

    feature '途中の言葉を取り除く' do
      background do
        within('.card-list') do
          click_link 'う'
          wait_for_ajax
        end

        within('.tab-button-list') do
          click_link 'ことばを取り除く'
          wait_for_ajax
        end
      end

      scenario '新しい組み合わせで検索した言葉が中央に表示されること' do
        within('.slide-item.on-center') do
          expect(page.find('.word-slide-item-name')).to have_content('言い伝え')
          expect(page.find('.word-slide-item-furigana')).to have_content('いいつたえ')
        end
      end

      scenario '最後の言葉がページから無くなっていること' do
        within('.slide-item.on-center') do
          expect(page).to have_no_content('浮世絵')
          expect(page).to have_no_content('うきよえ')
        end
      end
    end
  end
end
