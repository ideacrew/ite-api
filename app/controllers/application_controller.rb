# frozen_string_literal: true

# application controller
class ApplicationController < ActionController::API
  include RailsJwtAuth::AuthenticableHelper
  include Pundit::Authorization

  rescue_from RailsJwtAuth::NotAuthorized do |_exception|
    render json: { status_text: 'Could not authenticate', status: 401, content_type: 'application/json' }
  end
end
