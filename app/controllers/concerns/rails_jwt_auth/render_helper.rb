# frozen_string_literal: true
# # frozen_string_literal: true

# # app/controllers/concerns/rails_jwt_auth/render_helper.rb
#
# module RailsJwtAuth
#   # overriding the gemfile's render helper to modify the render_session
#   module RenderHelper
#     private

#     def render_session(jwt, _user)
#       # add custom field to session response
#       # render json: { session: { jwt:, role: 'skdhgfdjfghjdfghdfgh' } }, status: 201
#     end

#     def render_registration(resource)
#       render json: resource, root: true, status: 201
#     end

#     def render_profile(resource)
#       render json: resource, root: true, status: 200
#     end

#     def render_204
#       head 204
#     end

#     def render_404
#       head 404
#     end

#     def render_410
#       head 410
#     end

#     def render_422(errors)
#       render json: { errors: }, status: 422
#     end
#   end
# end
# # rubocop:enable Naming/VariableNumber
