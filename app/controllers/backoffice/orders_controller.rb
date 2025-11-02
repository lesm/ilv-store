# frozen_string_literal: true

module Backoffice
  class OrdersController < BaseController
    def index
      @orders = current_user.orders
                            .includes(
                              address: %i[city state],
                              items: [product: [:translations, { cover_attachment: :blob }]]
                            )
                            .where.not(workflow_status: :draft)
                            .order(created_at: :desc)
    end
  end
end
