require 'rails_helper'

RSpec.describe 'User Authentication', type: :system do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  describe 'ユーザーログイン' do
    it 'ログインページが表示される' do
      visit new_user_session_path
      expect(page).to have_content('ログイン')
    end

    it '正しい認証情報でログインできる' do
      visit new_user_session_path
      
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'password123'
      click_button 'ログイン'
      
      expect(page).to have_content('世帯を作成してください')
    end

    it '間違った認証情報ではログインできない' do
      visit new_user_session_path
      
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'wrongpassword'
      click_button 'ログイン'
      
      expect(page).to have_content('メールアドレスまたはパスワードが違います')
    end
  end

  describe 'ユーザー登録' do
    it '新規登録ページが表示される' do
      visit new_user_registration_path
      expect(page).to have_content('新規登録')
    end

    it '新しいユーザーを登録できる' do
      visit new_user_registration_path
      
      fill_in '名前', with: 'テストユーザー'
      fill_in 'メールアドレス', with: 'newuser@example.com'
      fill_in 'パスワード', with: 'password123'
      fill_in 'パスワード確認', with: 'password123'
      click_button 'アカウントを作成'
      
      expect(page).to have_content('世帯を作成してください')
    end
  end

  describe 'ログアウト' do
    before do
      sign_in user
    end

    it 'ログアウトできる' do
      visit root_path
      click_link 'ログアウト'
      
      expect(page).to have_content('ログイン')
    end
  end
end
