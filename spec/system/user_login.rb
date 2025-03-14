# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'UserLogin', type: :feature do
  let(:user) { User.create!(email: 'user@example.com', password: 'password') }

  scenario 'User logs in successfully' do
    visit new_user_session_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    expect(page).to have_content('Signed in successfully')
    expect(page).to have_current_path(root_path)
  end
end
