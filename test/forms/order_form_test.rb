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

  describe 'address atrributes' do
    test "do not clone 'id', 'created_at', 'updated_at' attributes" do
      assert form.expects(:address_attributes).returns(address_attributes)

      form.save
    end
  end

  describe 'clears the cart' do
    test 'after submitting the form' do
      form.save

      assert_empty current_cart.items
    end
  end

  describe 'enqueues the OrderMailerJob' do
    test 'with the order id and :send_order_created' do
      OrderMailerJob.expects(:perform_later).with(instance_of(String), :send_order_created)

      form.save
    end
  end
end
