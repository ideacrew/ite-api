# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

# Extend Dry Types
module Types # rubocop:disable Metrics/ModuleLength
  include Dry.Types
  include Dry::Logic

  RecordGroups =
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

  DISCHARGE_REASON_OPTIONS = {
    "1": 'Treatment Completed',
    "2": 'Dropout',
    "3": 'Terminated by Facility',
    "4": 'Transferred Successfully',
    "14": 'Transferred but No Show',
    "24": 'Transferred but Not Reportable',
    "5": 'Incarcerated',
    "6": 'Death by Suicide',
    "7": 'Death Not by Suicide',
    "34": 'Discharged from SH for Acute Care',
    "35": 'Conditional Release',
    "36": 'Change of Residence',
    "37": 'Aging Out',
    "95": 'Other',
    "96": 'Not applicable',
    "97": 'Unknown',
    "98": 'Not Collected'
  }.freeze

  GENDER_OPTIONS = {
    '1': 'Male',
    '2': 'Female',
    '97': 'Unknown',
    '98': 'Not Collected'
  }.freeze

  SEXUAL_ORIENTATION_OPTIONS = {
    '1': 'Lesbian, gay or homosexual',
    '2': 'Straight or heterosexual',
    '3': 'Bisexual',
    '4': 'Something else',
    '95': 'Prefer Not To Disclose',
    '97': 'Unknown',
    '98': 'Not Collected'
  }.freeze

  RACE_OPTIONS = {
    '1': 'Alaskan native (Aleut, Eskimo)',
    '2': 'American Indian/Alaska native ',
    '3': 'Asian or pacific islander',
    '4': 'Black or African American',
    '5': 'White',
    '13': 'Asian',
    '20': 'Other single race',
    '21': 'Two or more races',
    '23': 'Native Hawaiian or other pacific islander',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  ETHNICITY_OPTIONS = {
    '1': 'Puerto Rican',
    '2': 'Mexican',
    '3': 'Cuban',
    '4': 'Other specific Hispanic or Latino',
    '5': 'Not of Hispanic or Latino origin',
    '6': 'Hispanic or Latino, Not Specified',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  LANGUAGE_OPTIONS = {
    '01': 'Amharic',
    '02': 'Arabic',
    '03': 'Chinese',
    '04': 'English',
    '05': 'French',
    '06': 'German',
    '07': 'Hebrew',
    '08': 'Hindi',
    '09': 'Italian',
    '10': 'Korean',
    '11': 'Spanish',
    '12': 'Tagalog',
    '13': 'Urdu',
    '14': 'Vietnamese',
    '15': 'Other',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  REFERRAL_SOURCE_OPTIONS = {
    '01': 'Individual',
    '02': 'Alcohol/drug abuse care provider',
    '03': 'Other health care provider',
    '04': 'School (Educational)',
    '05': 'Employer/Employee Assistance Program (EAP)',
    '06': 'Other community referral',
    '07': 'Court/criminal justice referral/DUI/DWI',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  PAYMENT_SOURCE_OPTIONS = {
    '01': 'Self-pay',
    '02': 'Medicare',
    '03': 'Medicaid',
    '04': 'Tricare',
    '05': 'Alliance/ICP',
    '06': 'Other government funding',
    '07': "Worker's compensation",
    '08': 'Private health insurance companies',
    '09': 'No charge (free, charity, special research or teaching)',
    '96': 'Other',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  LIVING_ARRANGEMENT_OPTIONS = {
    '01': 'Homeless',
    '03': 'Independent Living - Adult',
    '11': 'Dependent Living with Caretaker',
    '12': 'Foster Care in Family Setting',
    '13': 'Foster Care Group Home',
    '14': 'Crisis Residence',
    '15': 'Institutional Setting',
    '16': 'Justice System',
    '17': 'Dependent Living – Not Specified',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  EDUCATION_OPTIONS = {
    '00': 'Less than one school grade',
    '01': 'Grade 1',
    '02': 'Grade 2 ',
    '03': 'Grade 3',
    '04': 'Grade 4',
    '05': 'Grade 5',
    '06': 'Grade 6',
    '07': 'Grade 7',
    '08': 'Grade 8',
    '09': 'Grade 9',
    '10': 'Grade 10',
    '11': 'Grade 11',
    '12': '12th Grade or GED',
    '13': '1st Year of college/university',
    '14': '2nd Year of college/university ',
    '15': '3rd Year of college/university',
    '16': '4th Year of college/university',
    '17': 'Some post-graduate study',
    '18': 'Graduate or professional degree',
    '71': 'Vocational school ',
    '72': 'Nursery, pre-school or head-start',
    '73': 'Kindergarten',
    '74': 'Self-contained special education class',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  EMPLOYMENT_OPTIONS = {
    '01': 'Full-time',
    '02': 'Part-time',
    '03': 'Unemployed',
    '04': 'Not in labor force',
    '05': 'Employed',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  LEGAL_STATUS_OPTIONS = {
    '01': 'Voluntary-self',
    '02': 'Voluntary-others (parents, guardians, etc)',
    '03': 'Involuntary-civil',
    '04': 'Involuntary-criminal',
    '05': 'Involuntary-juvenile justice',
    '06': 'Involuntary-civil, sexual',
    '96': "Not applicable - Use this code if 'Treatment Setting' is not ‘State psychiatric hospital",
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze

  ROUTE_OF_ADMINISTRATION_OPTIONS = {
    '01': 'Oral',
    '02': 'Smoking',
    '03': 'Inhalation',
    '04': 'Injection (intravenous, intramuscular, intradermal, or subcutaneous)',
    '20': 'Other',
    '96': 'Not applicable',
    '97': 'Unknown',
    '98': 'Not collected'
  }.freeze
end
