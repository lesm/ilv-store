# frozen_string_literal: true

require 'application_system_test_case'

class AddItemToTheCartWithUnauthenticatedUserTest < ApplicationSystemTestCase
  let(:translation) { build(:product_translation, locale: :en) }
  let(:product) { create(:product, translation:) }

  before do
    product
  end

  test 'adds item to the cart with unauthenticated user' do
    visit root_path(locale: :en)
    click_on product.title

    click_on 'Add to cart'

    assert_text 'You need to sign in or sign up before continuing.'
    assert_selector 'input[type="submit"][value="Sign in"]'
  end
end
