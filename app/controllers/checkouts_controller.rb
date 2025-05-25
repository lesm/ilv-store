# frozen_string_literal: true

class CheckoutsController < ApplicationController
  def new
    @address = current_user.default_address || current_user.addresses.first
  end
end
