# frozen_string_literal: true

module Api
  module V1
    # entity to define a service profile for use in payload validation
    class ClientProfile < Dry::Struct
      # Client ID
      # Marital Status at Admission
      # Veteran Status
      # Education at Admission
      # Education at Discharge
      # Employment Status at Admission
      # Employment Status at Discharge
      # Detailed Not-in-Labor Force
      # Source of Income/Support
      # Pregnant at Admission
      # School Attendance Status at Admission
      # School Attendance Status at Discharge
      # SH-Legal Status at Admission
      # Arrests in Past 30 Days prior to Admission
      # Frequency of Attendance at Self-Help Groups in Past 30 Days prior to Admission
      # Health Insurance
    end
  end
end
