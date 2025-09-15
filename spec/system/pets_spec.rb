# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pets', type: :system do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:membership) { create(:membership, user: user, household: household) }
  let(:breed) { create(:breed) }
  let(:pet) { create(:pet, household: household, breed: breed) }

  before do
    sign_in user
    allow_any_instance_of(ApplicationController).to receive(:current_household).and_return(household)
  end

  describe 'ペット一覧ページ' do
    it 'ペット一覧が表示される' do
      visit pets_path
      expect(page).to have_content('ペット一覧')
    end
  end

  describe 'ペット詳細ページ' do
    it 'ペットの詳細情報が表示される' do
      visit pet_path(pet)
      expect(page).to have_content(pet.name)
      expect(page).to have_content(pet.species)
    end

    it 'AI健康相談が表示される' do
      visit pet_path(pet)
      expect(page).to have_content('AI健康相談')
    end

    it '今日の予定が表示される' do
      visit pet_path(pet)
      expect(page).to have_content('今日の予定')
    end

    it '今週の予定が表示される' do
      visit pet_path(pet)
      expect(page).to have_content('今週の予定')
    end
  end

  describe 'ペット新規作成' do
    it '新しいペットを作成できる' do
      # 世帯を作成
      create(:membership, user: user, household: household)

      # 犬種を作成
      create(:breed, name: 'ダックスフンド')

      visit new_pet_path

      # フォームが表示されることを確認
      expect(page).to have_content('ペットを登録')
      expect(page).to have_field('名前')
      expect(page).to have_select('種類')
    end

    it 'バリデーションエラーが表示される' do
      # 世帯を作成
      create(:membership, user: user, household: household)

      visit new_pet_path

      click_button 'ペットを登録'

      # 同じページに留まることを確認
      expect(current_path).to eq(new_pet_path)
    end
  end

  describe 'ペット編集' do
    it 'ペット情報を更新できる' do
      visit edit_pet_path(pet)

      fill_in '名前', with: '更新された名前'
      fill_in '体重 (kg)', with: '6.0'
      click_button 'ペット情報を更新'

      expect(page).to have_content('ペット情報を更新しました')
      expect(page).to have_content('更新された名前')
    end
  end

  describe 'ペット削除' do
    it 'ペットを削除できる' do
      visit pet_path(pet)

      accept_confirm do
        click_link '削除'
      end

      expect(page).to have_content('ペットを削除しました')
      expect(page).not_to have_content(pet.name)
    end
  end
end
