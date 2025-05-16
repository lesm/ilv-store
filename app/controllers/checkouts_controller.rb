# frozen_string_literal: true

class CheckoutsController < ApplicationController
  def new
    @default_address = current_user.default_address
  end
end
