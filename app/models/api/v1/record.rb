# frozen_string_literal: true

module Api
  module V1
    # record model
    class Record
      include Mongoid::Document
      include Mongoid::Timestamps

      field :payload, type: Hash
      field :failures, type: Array
      field :warnings, type: Array
      # Valid or Invalid
      field :status, type: String
      field :provider_location, type: String, default: ''

      embedded_in :extract

      validates_presence_of :payload

      index({ status: 1 })
    end
  end
end
