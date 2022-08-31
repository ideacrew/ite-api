# frozen_string_literal: true

class ApplicationController < ActionController::API
  include RailsJwtAuth::AuthenticableHelper
end
