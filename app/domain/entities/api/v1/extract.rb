# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity for extract for use in validations
      class Extract < Dry::Struct
        attribute :provider_gateway_identifier, Types::String.meta(omittable: false)
        attribute :coverage_start, Types::Date.meta(omittable: false)
        attribute :coverage_end, Types::Date.meta(omittable: false)
        attribute :extracted_on, Types::Date.meta(omittable: false)
        attribute :file_name, Types::String.optional.meta(omittable: true)
        attribute :file_type, Types::String.meta(omittable: false)
        attribute :transaction_group, Types::String.meta(omittable: false)
      end
    end
  end
end
