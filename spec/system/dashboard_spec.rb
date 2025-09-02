require 'rails_helper'

RSpec.describe 'Dashboard', type: :system do
  let(:user) { create(:user) }
  let(:household) { create(:household) }
  let(:membership) { create(:membership, user: user, household: household) }

  before do
    sign_in user
    allow_any_instance_of(ApplicationController).to receive(:current_household).and_return(household)
  end

  describe 'ダッシュボードページ' do
    it 'ダッシュボードが表示される' do
      visit root_path
      expect(page).to have_content('ダッシュボード')
    end

    it '今月の予定セクションが表示される' do
      visit root_path
      expect(page).to have_content('今月の予定')
    end

    it '未完了セクションが表示される' do
      visit root_path
      expect(page).to have_content('未完了')
    end

    it 'クイックアクションセクションが表示される' do
      visit root_path
      expect(page).to have_content('クイックアクション')
    end
  end
end
