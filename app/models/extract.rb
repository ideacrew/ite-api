class Extract
	include Mongoid::Document
	include Mongoid::Timestamps

	field :payload, type: Hash
	field :provider_identifier, type: String
	field :npi, type: String
	field :coverage_start, type: Date
	field :coverage_end, type: Date
	field :extracted_on, type: Date
	field :file_name, type: String
	field :file_type, type: String
	# Should be admission, discharge and update?
	field :extract_type, type: String
	field :failures, type: Hash
	field :status, type: String

	validates_presence_of :provider_identifier

	index({provider_identifier: 1}, {sparse: true})

	def coverage_range
	  coverage_start.beginning_of_day..coverage_end.end_of_day
	end

end