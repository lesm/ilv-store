# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def save
    return false unless valid?

    with_transaction { submit }
  end

  private

  def submit
    raise NotImplementedError, 'You must implement the submit method in your form class'
  end

  def with_transaction(&)
    ActiveRecord::Base.transaction do
      yield
      true
    rescue StandardError => e
      errors.add(:base, e.message)
      raise ActiveRecord::Rollback
    end
  end
end
