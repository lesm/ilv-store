# frozen_string_literal: true

require 'test_helper'

class OrderFormTest < ActiveSupport::TestCase
  let(:current_user) { create(:user, :with_cart) }
  let(:current_cart) { current_user.cart }
  let(:address) { create(:address, :oxxo_bustamante, addressable: current_user) }

  let(:form) { OrderForm.new(address_id: address.id, current_cart:, current_user:) }

  let(:address_attributes) do
    {
      'country_id' => address.country_id,
      'street_and_number' => address.street_and_number,
      'postal_code' => address.postal_code,
      'reference' => address.reference,
      'state_id' => address.state_id,
      'city_id' => address.city_id,
      'neighborhood' => address.neighborhood,
      'full_name' => address.full_name,
      'phone_number' => address.phone_number,
      'default' => false,
      'addressable_type' => address.addressable_type,
      'addressable_id' => address.addressable_id
    }
  end

  describe 'validations' do
    test 'is invalid without an address_id' do
      form.address_id = nil

      assert_not form.valid?
      assert form.errors.key?(:address_id)
    end
  end

  describe 'address attributes' do
    test "do not clone 'id', 'created_at', 'updated_at' attributes" do
      assert form.expects(:address_attributes).returns(address_attributes)

      form.save
    end
  end

  describe 'updates product stock' do
    test 'after submitting the form' do
      quantities = current_cart.items.pluck(:product_id, :quantity).to_h
      initial_stocks = Product.where(id: quantities.keys).pluck(:id, :stock).to_h

      # The save method clears the cart items
      form.save

      initial_stocks.each do |id, stock|
        assert_equal stock - quantities[id], Product.find(id).stock
      end
    end
  end

  describe '#save' do
    describe 'clears the cart' do
      test 'after submitting the form' do
        form.save

        assert_empty current_cart.items
      end
    end
  end
end
