# frozen_string_literal: true

module RailsJwtAuth
  # overwriting this from the gem
  module RenderHelper
    # rubocop:disable Naming/VariableNumber
    def render_session(jwt, user)
      auth_field = RailsJwtAuth.auth_field_name
      render json: { session: { jwt:, auth_field => user[auth_field] } }, status: 201
    end

    def render_registration(resource)
      render json: resource, root: true, status: 201
    end

    def render_profile(resource)
      render json: resource, root: true, status: 200
    end

    def render_204
      head 204
    end

    def render_404
      head 404
    end

    def render_410
      head 410
    end

    def render_422(_errors)
      user = User.all.detect { |u| u.email == params['email'] } if params['email']
      error_text = user.present? ? 'Invalid credentials' : 'Invalid email'
      render json: { error: error_text }, status: 422
    rescue Mongoid::Errors::DocumentNotFound
      render json: { error: 'Invalid email' }, status: 422
    end

    # rubocop:enable Naming/VariableNumber
  end
end
