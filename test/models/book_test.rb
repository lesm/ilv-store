# frozen_string_literal: true

require 'test_helper'

class BookTest < ActiveSupport::TestCase
  let(:book) { build(:book) }

  test 'builds a valid book' do
    assert book.valid?
  end

  describe '#validations' do
    %i[language language_zone edition_number pages_number internal_code cover_color dimensions weight_grams]
      .each do |attribute|
        test "validates presence of #{attribute}" do
          book.public_send("#{attribute}=", nil)
          assert book.invalid?
        end
      end

    test 'validates uniqueness of internal_code' do
      existing_book = create(:book, internal_code: 'UNIQUE123')
      book.internal_code = existing_book.internal_code

      assert book.invalid?
    end
  end
end
