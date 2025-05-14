# frozen_string_literal: true

class PostalCodesController < ApplicationController
  def index
    return render json: { error: 'postal_code param is required' }, status: :bad_request if params[:postal_code].blank?

    @postal_codes = MxPostalCode.includes(:state, :city).where(postal_code: params[:postal_code])

    render json: { error: 'Postal code not found' }, status: :not_found and return if @postal_codes.empty?

    respond_to do |format|
      format.json { render :index }
    end
  end
end
