class Extract
	include Mongoid::Document
	include Mongoid::Timestamps

	field :payload, type: Hash
	field :provider_identifier, type: String
	# Should be admission, discharge and update
	field :extract_type, type: String
	field :failures, type: Hash
	field :status, type: String

	validates_presence_of :provider_identifier

	index({provider_identifier: 1}, {sparse: true})

end