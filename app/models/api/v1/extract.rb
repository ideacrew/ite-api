# frozen_string_literal: true

module Api
  module V1
    # extract model
    class Extract
      include Mongoid::Document
      include Mongoid::Timestamps

      belongs_to :provider, inverse_of: :extracts, class_name: 'Api::V1::Provider'

      # field :payload, type: Hash
      field :provider_gateway_identifier, type: String
      field :coverage_start, type: Date
      field :coverage_end, type: Date
      field :extracted_on, type: Date
      field :file_name, type: String
      field :status, type: String

      has_many :records, inverse_of: :extract, class_name: 'Api::V1::Record'

      accepts_nested_attributes_for :records

      validates_presence_of :provider_gateway_identifier, :coverage_start, :coverage_end, :extracted_on

      index({ provider_gateway_identifier: 1 }, { sparse: true })

      def coverage_range
        coverage_start..coverage_end
      end

      def record_count
        return 0 unless records.present?

        records&.count
      end

      def record_critical_errors_count
        return 0 unless records.present?

        records&.select { |t| t.critical_errors.any? }&.count
      end

      def record_fatal_errors_count
        return 0 unless records.present?

        records&.select { |t| t.fatal_errors.any? }&.count
      end

      def record_warning_count
        return 0 unless records.present?

        records&.select { |t| t.warnings&.any? }&.count
      end

      def pass_count
        return 0 unless records.present?

        records&.select { |t| t.status == 'Pass' }&.count
      end

      def fail_count
        return 0 unless records.present?

        records&.select { |t| t.status == 'Fail' }&.count
      end

      def list_view
        {
          id: id.to_s,
          coverage_end:,
          coverage_start:,
          submission_date: created_at,
          number_of_records: record_count,
          record_critical_errors_count:,
          record_fatal_errors_count:,
          record_warning_count:,
          pass_count:,
          fail_count:,
          status:
        }
      end
    end
  end
end
