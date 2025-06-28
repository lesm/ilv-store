# frozen_string_literal: true

require 'test_helper'

class BookTest < ActiveSupport::TestCase
  let(:book) { build(:book) }

  test 'builds a valid book' do
    assert book.valid?
  end

  describe '#validations' do
    test 'validates presence of language' do
      book.language = nil

      assert book.invalid?
    end

    test 'validates presence of language_zone' do
      book.language_zone = nil

      assert book.invalid?
    end

    test 'validates presence of edition_number' do
      book.edition_number = nil

      assert book.invalid?
    end

    test 'validates presence of pages_number' do
      book.pages_number = nil

      assert book.invalid?
    end

    test 'validates presence of internal_code' do
      book.internal_code = nil

      assert book.invalid?
    end

    test 'validates uniqueness of internal_code' do
      existing_book = create(:book, internal_code: 'UNIQUE123')
      book.internal_code = existing_book.internal_code

      assert book.invalid?
    end
  end
end
