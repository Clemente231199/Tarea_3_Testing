# frozen_string_literal: true

require 'application_system_test_case'

class NavigationsTest < ApplicationSystemTestCase
  test 'log in' do
    visit root

    assert_selector 'h1', text: 'Navigation'
  end
end
