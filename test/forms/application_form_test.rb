# frozen_string_literal: true

require 'test_helper'

class ApplicationFormTest < ActiveSupport::TestCase
  let(:form) { ApplicationForm.new }

  TestForm = Class.new(ApplicationForm) do
    def submit
      raise StandardError, 'Test error'
    end
  end

  describe '#save' do
    test 'raises NotImplementedError' do
      assert_raises NotImplementedError do
        form.save
      end
    end
  end

  describe 'rescues from StandardError' do
    let(:form) { TestForm.new }

    test 'adds error to the form' do
      assert_not form.save
      assert_includes form.errors[:base], 'Test error'
    end
  end
end
