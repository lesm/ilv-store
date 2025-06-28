# frozen_string_literal: true

require 'test_helper'

class Product
  class TranslationTest < ActiveSupport::TestCase
    let(:translation) { build(:product_translation) }

    test 'builds a valid translation' do
      assert translation.valid?
    end

    describe '#validations' do
      test 'validates presence of locale' do
        translation.locale = nil

        assert translation.invalid?
      end

      test 'validates numericality greater than 0 for price' do
        translation.price = -10

        assert translation.invalid?
      end

      test 'validates inclusion of locale' do
        translation.locale = 'fr'

        assert translation.invalid?
      end
    end
  end
end
