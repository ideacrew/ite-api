# frozen_string_literal: true

module Api
  module V1
    # transaction model
    class Transaction
      include Mongoid::Document
      include Mongoid::Timestamps

      field :payload, type: Hash
      field :failures, type: Hash
      field :warnings, type: Hash
      field :status, type: String

      embedded_in :extract

      validates_presence_of :payload

      index({ status: 1 })

      # add validation to identify the warnings as opposed to the failures -> need to know what those fields are
    end
  end
end
