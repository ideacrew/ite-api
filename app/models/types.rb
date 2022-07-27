# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

# Extend Dry Types
module Types
  include Dry.Types
  include Dry::Logic

  TransactionGroups =
    Types::String.enum('admission', 'discharge', 'update').freeze

  CODEPEDENT_OPTIONS = {
    "1": 'Codependent/Collateral',
    "2": 'Client'
  }.freeze

  RECORD_TYPE_OPTIONS = {
    "A": 'Initial Admission for SU Treatment',
    "T": 'Transfer in SU Service',
    "D": 'Discharge from SU Treatment',
    "M": 'Initial Admission for MH Treatment',
    "X": 'Transfer/Change in MH Service',
    "E": 'Discharge from MH Treatment'
  }.freeze

  TREATMENT_TYPE_OPTIONS = {
    "1": 'Detoxification, 24-hour service, hospital inpatient',
    "2": 'Detoxification, 24 hour service, free-standing residential',
    "3": 'Rehabilitation/residential - hospital (other than detoxification)',
    "4": 'Rehabilitation/residential - short term (30 days or fewer)',
    "5": 'Rehabilitation/residential - long term (more than 30 days)',
    "6": 'Ambulatory - intensive outpatient',
    "7": 'Ambulatory - non-intensive outpatient',
    "8": 'Ambulatory - detoxification',
    "72": 'State psychiatric hospital',
    "73": 'SMHA funded/operated community-based program',
    "74": 'Residential treatment center',
    "75": 'Other psychiatric inpatient',
    "76": 'Institutions under the justice system',
    "77": 'MH Assessment/Screening',
    "96": 'Not applicable - use only for codependents or collateral clients (SA))'
  }.freeze
end
