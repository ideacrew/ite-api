# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity for record for use in validations
      class Record < Dry::Struct
        attribute :payload, Types::Hash.meta(omittable: false)
      end
    end
  end
end
