# frozen_string_literal: true

require 'test_helper'

class OrderFormTest < ActiveSupport::TestCase
  let(:current_user) { create(:user, :with_cart) }
  let(:current_cart) { current_user.cart }
  let(:address) { create(:address, :oxxo_bustamante, addressable: current_user) }
  let(:requires_invoice) { '0' }
  let(:form) do
    OrderForm.new(address_id: address.id, current_cart:, current_user:, requires_invoice:)
  end

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

  describe 'updates product reserved_stock' do
    test 'after submitting the form' do
      quantities = current_cart.items.pluck(:product_id, :quantity).to_h
      reserved_stocks = Product.where(id: quantities.keys).pluck(:id, :reserved_stock).to_h

      form.save

      reserved_stocks.each do |id, reserved_stock|
        assert_equal reserved_stock + quantities[id], Product.find(id).reserved_stock
      end
    end
  end

  describe '#save' do
    describe 'creates an order' do
      let(:requires_invoice) { '1' }

      test 'with the correct attributes' do
        assert_difference 'Order.count', 1 do
          form.save
        end

        order = form.order

        assert_equal current_user, order.user
        assert_equal 'draft', order.workflow_status
        assert_equal current_cart.subtotal_price, order.subtotal
        assert_equal current_cart.total_price, order.total
        # TODO: fix type issue
        # assert_equal address_attributes, order.address.attributes.except('id', 'created_at', 'updated_at', 'type')
        assert_equal current_cart.items.count, order.items.count
        assert_equal true, order.requires_invoice

        current_cart.items.each_with_index do |item, index|
          order_item = order.items[index]

          assert_equal item.product_id, order_item.product_id
          assert_equal item.quantity, order_item.quantity
          assert_equal item.price, order_item.price
        end
      end
    end
  end
end
