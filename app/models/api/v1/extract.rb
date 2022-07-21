# frozen_string_literal: true

module Api
  module V1
    # extract model
    class Extract
      include Mongoid::Document
      include Mongoid::Timestamps

      # field :payload, type: Hash
      field :provider_gateway_identifier, type: String
      field :coverage_start, type: Date
      field :coverage_end, type: Date
      field :extracted_on, type: Date
      field :file_name, type: String
      # Initial, Resubmission, Update
      field :file_type, type: String
      # Should be admission, discharge and update?
      field :transaction_group, type: String
      # field :failures, type: Hash
      field :status, type: String

      embeds_many :transactions, cascade_callbacks: true, validate: true

      accepts_nested_attributes_for :transactions

      validates_presence_of :provider_gateway_identifier, :coverage_start, :coverage_end, :extracted_on, :file_type,
                            :transaction_group

      index({ provider_gateway_identifier: 1 }, { sparse: true })

      def coverage_range
        coverage_start..coverage_end
      end
    end
  end
end
