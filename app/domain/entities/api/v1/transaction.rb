# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity for transaction for use in validations
      class Transaction < Dry::Struct
        attribute :payload, Types::Hash.meta(omittable: false)
      end
    end
  end
end
