# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity for extract for use in validations
      class Extract < Dry::Struct
        attribute :provider_identifier, Types::String.meta(omittable: false)
        attribute :npi, Types::String.optional.meta(omittable: true)
        attribute :coverage_start, Types::Date.optional.meta(omittable: true)
        attribute :coverage_end, Types::Date.optional.meta(omittable: true)
        attribute :extracted_on, Types::Date.optional.meta(omittable: true)
        attribute :file_name, Types::String.optional.meta(omittable: true)
        attribute :file_type, Types::String.optional.meta(omittable: true)
        attribute :transaction_group, Types::String.optional.meta(omittable: true)
      end
    end
  end
end
