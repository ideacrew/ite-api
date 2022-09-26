# frozen_string_literal: true

module RailsJwtAuth
  # overwriting this from the gem
  module RenderHelper
    # rubocop:disable Naming/VariableNumber
    def render_session(jwt, user)
      auth_field = RailsJwtAuth.auth_field_name
      if params['formLocation'] == 'ITE Portal' && !user.dbh_user?
        render json: 'Invalid credentials', status: 422
      else
        render json: { session: { jwt:, auth_field => user[auth_field] } }, status: 201
      end
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
      render json: 'Invalid credentials', status: 422
    end

    # rubocop:enable Naming/VariableNumber
  end
end
