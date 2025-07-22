# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  helper :application

  def created
    @order = params[:order]
    mail subject: t('.subject'), to: email_address_with_name(@order.user.email, @order.user.name)
  end
end
