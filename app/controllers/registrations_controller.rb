# frozen_string_literal: true

class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  layout 'session'

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      AccountMailerJob.perform_later(@user.id, :send_verify_email)

      redirect_to new_session_path, notice: t('.success')
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: %i[country_id name email password password_confirmation])
  end
end
