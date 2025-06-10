# frozen_string_literal: true

require 'test_helper'

module Email
  module Providers
    class BaseProviderTest < ActiveSupport::TestCase
      class TestProvider < Email::Providers::BaseProvider
        def send_email(*)
          true
        end
      end

      let(:provider) { TestProvider.new }

      describe '#send_email' do
        test 'raises NotImplementedError' do
          assert_raises(NotImplementedError) do
            Email::Providers::BaseProvider.new.send_email(message_delivery: nil)
          end
        end

        test 'does not raise the NotImplementedError' do
          assert_nothing_raised do
            provider.send_email(message_delivery: nil)
          end
        end
      end
    end
  end
end
