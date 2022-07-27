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

      # embedded_in :provider
      embeds_many :transactions, cascade_callbacks: true, validate: true

      accepts_nested_attributes_for :transactions

      validates_presence_of :provider_gateway_identifier, :coverage_start, :coverage_end, :extracted_on, :file_type,
                            :transaction_group

      index({ provider_gateway_identifier: 1 }, { sparse: true })

      def coverage_range
        coverage_start..coverage_end
      end

      def transaction_count
        return 0 unless transactions.present?

        transactions&.count
      end

      def transaction_failure_count
        return 0 unless transactions.present?

        transactions&.select { |t| t.failures.any? }&.count
      end

      def transaction_warning_count
        return 0 unless transactions.present?

        transactions&.select { |t| t.warnings.any? }&.count
      end

      def list_view
        {
          id: id.to_s,
          coverage_end:,
          coverage_start:,
          submission_date: created_at,
          file_type:,
          transaction_group:,
          number_of_transactions: transaction_count,
          transaction_failure_count:,
          transaction_warning_count:
        }
      end
    end
  end
end
