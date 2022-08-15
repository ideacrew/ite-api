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
      field :record_group, type: String
      field :status, type: String

      embedded_in :provider
      embeds_many :records, cascade_callbacks: true, validate: true

      accepts_nested_attributes_for :records

      validates_presence_of :provider_gateway_identifier, :coverage_start, :coverage_end, :extracted_on,
                            :record_group

      index({ provider_gateway_identifier: 1 }, { sparse: true })

      def coverage_range
        coverage_start..coverage_end
      end

      def record_count
        return 0 unless records.present?

        records&.count
      end

      def failed_record_count
        return 0 unless records.present?

        records&.select { |t| t.failures.any? }&.count
      end

      def warned_record_count
        return 0 unless records.present?

        records&.select { |t| t.warnings.any? }&.count
      end

      def list_view
        {
          id: id.to_s,
          coverage_end:,
          coverage_start:,
          submission_date: created_at,
          record_group:,
          number_of_records: record_count,
          record_failure_count: failed_record_count,
          record_warning_count: warned_record_count,
          status:
        }
      end
    end
  end
end
