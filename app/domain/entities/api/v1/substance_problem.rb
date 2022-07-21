# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity to define a substance problem for use in payload validation
      class SubstanceProblem < Dry::Struct
        # substance
        attribute :substance, Types::String.optional.meta(omittable: true) # type unconfirmed
        # level (primary/secondar/tertiary)
        attribute :level, Types::String
        # Detailed Drug Code
        attribute :drug_code, Types::Integer.optional.meta(omittable: true)
        # Age at First Use
        attribute :age_at_first_use, Types::Integer.optional.meta(omittable: true)
        # Frequency of Use
        attribute :frequency, Types::String.optional.meta(omittable: true)
        # Route of Administration
        attribute :route, Types::String.optional.meta(omittable: true)
      end
    end
  end
end
