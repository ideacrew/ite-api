# frozen_string_literal: true

module Api
  module V1
    # record model
    class Record
      include Mongoid::Document
      include Mongoid::Timestamps

      field :payload, type: Hash
      field :warnings, type: Array
      field :critical_errors, type: Array
      field :fatal_errors, type: Array
      field :status, type: String

      belongs_to :extract, inverse_of: :records, class_name: 'Api::V1::Extract'

      validates_presence_of :payload

      index({ status: 1 })

      OPTIONAL_FIELDS = %i[address_ward ssn address_zipcode phone1 phone2 veteran_status not_in_labor income_source pregnant medicaid_id suffix sexual_orientation first_name_alt
                           last_name_alt self_help_group_admission middle_name suffix admission_id service_request_date criminal_justice_referral
                           health_insurance address_line2 address_line1 address_city address_state co_occurring_sud_mh non_bh_dx1 non_bh_dx2
                           non_bh_dx3 sud_dx2 sud_dx3 mh_dx2 mh_dx3 primary_payment_source secondary_substance tertiary_substance secondary_su_frequency_admission tertiary_su_frequency_admission
                           secondary_su_frequency_discharge tertiary_su_frequency_discharge secondary_su_route tertiary_su_route secondary_su_age_at_first_use tertiary_su_age_at_first_use].freeze
      REQUIRED_FIELDS = %i[gaf_score_admission smi_sed school_attendance marital_status employment education primary_su_frequency_admission
                           legal_status primary_language ethnicity race first_name last_name dob gender self_help_group_discharge primary_su_frequency_discharge
                           arrests_past_30days_discharge num_of_prior_su_episodes gaf_score_discharge sud_dx1 mh_dx1 opioid_therapy primary_su_age_at_first_use
                           discharge_reason referral_source living_arrangement arrests_past_30days_admission primary_substance primary_su_frequncy_admission primary_su_route].freeze
      KEY_FIELDS = %i[collateral client_id record_type admission_date treatment_type discharge_date last_contact_date].freeze

      def details
        return attributes unless payload[:ssn]

        attributes['payload']['ssn'] = obscure_ssn(payload[:ssn])
        attributes
      end

      def obscure_ssn(original_ssn)
        return "***-**-#{original_ssn[-4..]}" if original_ssn.length == 9
        return "#{'*' * (original_ssn.length - 4)}#{original_ssn[-4..]}" if original_ssn.length > 9

        '*' * original_ssn.length
      end

      def errors_by_field_array
        failing_data_fields_array = []
        record_id = build_record_id
        warnings.each { |warning| failing_data_fields_array << field_error_array(warning, record_id) }
        critical_errors.each { |critical_error| failing_data_fields_array << field_error_array(critical_error, record_id) }
        fatal_errors.each { |critical_error| failing_data_fields_array << field_error_array(critical_error, record_id) }
        failing_data_fields_array.flatten
      end

      def field_error_array(error, record_id)
        error_fields_array = []
        field_name = error.to_h.keys.first
        field_type = field_type(field_name.to_sym)
        error.to_h.each_value do |error_value|
          error_type = error_value['category']
          error_message = error_value['text']
          input = field_name != 'ssn' ? payload[field_name] : obscure_ssn(payload[field_name])
          error_fields_array << { field_name:, field_type:, error_type:, record_id:, error_message:, input: }
        end
        error_fields_array.flatten
      end

      def build_record_id
        client_id = payload[:client_id].present? ? payload[:client_id] : 'no-client-id'
        admission_date = payload[:admission_date].present? ? valid_date(payload[:admission_date]) : 'no-admission-date'
        record_type = payload[:record_type].present? ? payload[:record_type] : 'no-record-type'
        treatment_type = payload[:treatment_type].present? ? payload[:treatment_type] : 'no-treatment-type'
        "#{client_id}_#{admission_date}_#{record_type}#{treatment_type}"
      end

      def valid_date(value)
        re = Regexp.new('^([1-9]|0[1-9]|1[0-2])\/([1-9]|(0[1-9]|1[0-9]|2[0-9]|3[0-1]))\/\d{4}$').freeze
        return DateTime.strptime(value, '%m/%d/%Y').iso8601.slice(0, 10) if value.match(re)

        re = Regexp.new('^([1-9]|0[1-9]|1[0-2])\-([1-9]|(0[1-9]|1[0-9]|2[0-9]|3[0-1]))\-\d{4}$').freeze
        return DateTime.strptime(value, '%m-%d-%Y').iso8601.slice(0, 10) if value.match(re)

        re = Regexp.new('^\d{4}\-([1-9]|0[1-9]|1[0-2])\-([1-9]|(0[1-9]|1[0-9]|2[0-9]|3[0-1]))$').freeze
        return DateTime.strptime(value, '%Y-%m-%d').iso8601.slice(0, 10) if value.match(re)
      rescue StandardError
        'no-admission-date'
      end

      def field_type(field_name)
        return 'Optional Field' if Api::V1::Record::OPTIONAL_FIELDS.include? field_name
        return 'Required Field' if Api::V1::Record::REQUIRED_FIELDS.include? field_name
        return 'Key Field' if Api::V1::Record::KEY_FIELDS.include? field_name

        'nil'
      end
    end
  end
end
