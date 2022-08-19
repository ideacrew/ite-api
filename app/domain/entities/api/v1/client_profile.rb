# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity to define a service profile for use in payload validation
      class ClientProfile < Dry::Struct
        # Client ID
        attribute :client_id, Types::String
        # Marital Status at Admission
        attribute :marital_status, Types::String.optional.meta(omittable: true)
        # Veteran Status
        attribute :veteran_status, Types::String.optional.meta(omittable: true)
        # Education level
        attribute :education, Types::String.optional.meta(omittable: true)
        # Employment Status
        attribute :employment, Types::String.optional.meta(omittable: true)
        # Detailed Not-in-Labor Force
        attribute :not_in_labor, Types::String.optional.meta(omittable: true)
        # Source of Income/Support
        attribute :income_source, Types::String.optional.meta(omittable: true)
        # Pregnancy status
        attribute :pregnant, Types::String.optional.meta(omittable: true)
        # School Attendance Status
        attribute :school_attendance, Types::String.optional.meta(omittable: true)
        # Legal Status
        attribute :legal_status, Types::String.optional.meta(omittable: true)
        # Arrests in Past 30 Days prior to Admission
        attribute :arrests_past_30days_admission, Types::String.optional.meta(omittable: true) # type tbc??
        attribute :arrests_past_30days_discharge, Types::String.optional.meta(omittable: true) # type tbc??
        # Frequency of Attendance at Self-Help Groups in Past 30 Days prior to Admission
        attribute :self_help_group_admission, Types::String.optional.meta(omittable: true) # type tbc??
        attribute :self_help_group_discharge, Types::String.optional.meta(omittable: true) # type tbc??
        # Health Insurance
        attribute :health_insurance, Types::String.optional.meta(omittable: true) # type tbc??
      end
    end
  end
end
