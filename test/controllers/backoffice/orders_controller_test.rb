# frozen_string_literal: true

require 'test_helper'

module Backoffice
  class OrdersControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :admin) }
    let(:order) { create(:order, :order_created, user: user) }

    before do
      authenticate_as(user)
    end

    describe '#GET index' do
      test 'returns success response' do
        create_list(:order, 3, :order_created)

        get backoffice_orders_url
        assert_response :success
      end
    end

    describe '#GET edit' do
      test 'returns success response' do
        get edit_backoffice_order_url(order)
        assert_response :success
      end
    end

    describe '#PATCH update' do
      describe 'with valid params' do
        test 'updates order tracking number' do
          patch backoffice_order_url(order), params: {
            order: {
              tracking_number: 'TRACK123',
              carrier_name: 'FedEx'
            }
          }

          order.reload
          assert_equal 'TRACK123', order.tracking_number
        end

        test 'updates order carrier name' do
          patch backoffice_order_url(order), params: {
            order: {
              tracking_number: 'TRACK123',
              carrier_name: 'FedEx'
            }
          }

          order.reload
          assert_equal 'FedEx', order.carrier_name
        end

        test 'redirects to backoffice orders path on success' do
          patch backoffice_order_url(order), params: {
            order: {
              tracking_number: 'TRACK123',
              carrier_name: 'FedEx'
            }
          }

          assert_redirected_to backoffice_orders_path
        end

        test 'sets flash notice on success' do
          patch backoffice_order_url(order), params: {
            order: {
              tracking_number: 'TRACK123',
              carrier_name: 'FedEx'
            }
          }

          assert_equal I18n.t('backoffice.orders.update.success'), flash[:notice]
        end

        test 'returns see_other status on success' do
          patch backoffice_order_url(order), params: {
            order: {
              tracking_number: 'TRACK123',
              carrier_name: 'FedEx'
            }
          }

          assert_response :see_other
        end
      end

      describe 'with invalid params' do
        test 'rejects empty string for tracking_number' do
          I18n.with_locale(:en) do
            patch backoffice_order_url(order, format: :turbo_stream), params: {
              order: {
                tracking_number: '',
                carrier_name: 'FedEx'
              }
            }

            assert_response :unprocessable_entity
            assert_equal "Tracking number can't be blank", flash[:alert]
          end
        end

        test 'rejects empty string for carrier_name' do
          I18n.with_locale(:en) do
            patch backoffice_order_url(order), params: {
              order: {
                tracking_number: 'TRACK123',
                carrier_name: ''
              }
            }

            assert_response :unprocessable_entity
            assert_equal "Carrier name can't be blank", flash[:alert]
          end
        end
      end
    end

    describe '#POST send_in_transit_email' do
      test 'sends in transit email if order is eligible' do
        order.update(tracking_number: 'TRACK123', carrier_name: 'FedEx', payment_status: :paid)

        post send_in_transit_email_backoffice_order_url(order)

        assert_redirected_to backoffice_orders_path
        assert_equal I18n.t('backoffice.orders.send_in_transit_email.success'), flash[:notice]
        assert_not_nil order.reload.in_transit_email_sent_at
      end

      test 'does not send in transit email if order is not eligible' do
        order.update(payment_status: :pending)

        post send_in_transit_email_backoffice_order_url(order)

        assert_redirected_to backoffice_orders_path
        assert_equal I18n.t('backoffice.orders.send_in_transit_email.error'), flash[:alert]
        assert_nil order.reload.in_transit_email_sent_at
      end
    end
  end
end
