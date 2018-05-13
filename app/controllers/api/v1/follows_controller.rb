# frozen_string_literal: true

class Api::V1::FollowsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  respond_to :json

  def create
    raise ActiveRecord::RecordNotFound if follow_params[:uri].blank?

    @account = FollowService.new.call(current_user.account, target_uri).try(:target_account)

    if @account.nil?
      username, domain = target_uri.split('@')
      @account         = Account.find_by_username!(username, domain)
    end

    render json: @account, serializer: REST::AccountSerializer
  end

  private

  def target_uri
    follow_params[:uri].strip.gsub(/\A@/, '')
  end

  def follow_params
    params.permit(:uri)
  end
end
