# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  helper :application

  def created
    @order = params[:order]
    mail subject: t('.subject'),
         to: email_address_with_name(@order.user.email, @order.user.name),
         cc: ENV.fetch('SALES_EMAIL_ADDRESS', 'mail@mail.com')
  end

  def in_transit
    @order = params[:order]
    mail subject: t('.subject'), to: email_address_with_name(@order.user.email, @order.user.name)
  end
end
