# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity for extract for use in validations
      class Provider < Dry::Struct
        attribute :provider_name, Types::String.meta(omittable: false)
        attribute :provider_nick_name, Types::String.meta(omittable: true)
        attribute :npi, Types::String.optional.meta(omittable: true)
        attribute :is_active, Types::Bool.meta(omittable: false)
        attribute :mh, Types::Bool.optional.meta(omittable: true)
        attribute :sud, Types::Bool.meta(omittable: false)
        attribute :adult_care, Types::Bool.meta(omittable: false)
        attribute :child_care, Types::Bool.meta(omittable: false)
        attribute :office_locations, Types::Array.of(Types::Hash).optional.meta(omittable: true)
      end
    end
  end
end
