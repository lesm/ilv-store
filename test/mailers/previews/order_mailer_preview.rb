# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def created
    OrderMailer.with(order:).created if order.present?
  end

  private

  def order
    @order ||= Order.includes(items: [product: [:translations, { cover_attachment: :blob }]]).last
  end
end
