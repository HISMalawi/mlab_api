Rails.logger = Logger.new(STDOUT)
# Client Identifier types
client_identifier_types = ['cellphone_number', 'occupation', 'current_district',
  'current_traditional_authority', 'current_village', 'home_village', 'home_district', 
  'home_traditional_authority', 'art_number', 'htn_number'
]
client_identifier_types.each do |identifier_type|
  if ClientIdentifierType.find_by_name(identifier_type).nil?
    Rails.logger.info("Loading client identifier type #{identifier_type}")
    ClientIdentifierType.create!(name: identifier_type)
  end
end

FacilitySection.create!([
	{
		"name": "Other"
	},
	{
		"name": "CWC"
	},
	{
		"name": "CW HDU"
	},
	{
		"name": "CWB"
	},
	{
		"name": "CWA"
	},
	{
		"name": "Theatre"
	},
	{
		"name": "Dialysis Unit"
	},
	{
		"name": "ICU"
	},
	{
		"name": "1A"
	},
	{
		"name": "1B"
	},
	{
		"name": "2A"
	},
	{
		"name": "2B"
	},
	{
		"name": "Oncology"
	},
	{
		"name": "3A"
	},
	{
		"name": "3B"
	},
	{
		"name": "4A"
	},
	{
		"name": "4B"
	},
	{
		"name": "CWA EZ"
	},
	{
		"name": "CW Red Zone"
	},
	{
		"name": "CSSD"
	},
	{
		"name": "Dental"
	},
	{
		"name": "Mortuary"
	},
	{
		"name": "Anesthesia"
	},
	{
		"name": "Casulty"
	},
	{
		"name": "EM LW"
	},
	{
		"name": "EM HDU"
	},
	{
		"name": "EM THEATRE"
	},
	{
		"name": "EM Nursery"
	},
	{
		"name": "GYNAE"
	},
	{
		"name": "PNW"
	},
	{
		"name": "Paying Ward"
	},
	{
		"name": "MSS"
	},
	{
		"name": "HDU"
	},
	{
		"name": "MHDU"
	},
	{
		"name": "SHDU"
	},
	{
		"name": "Physiotherapy"
	},
	{
		"name": "Eye Ward"
	},
	{
		"name": "ANW"
	},
	{
		"name": "Facilities"
	},
	{
		"name": "Bwaila Hospital"
	},
	{
		"name": "Kawale Health Centre"
	},
	{
		"name": "Dowa District Hospital"
	},
	{
		"name": "Light House"
	},
	{
		"name": "Dedza District Hospital"
	},
	{
		"name": "Ntcheu District Hospital"
	},
	{
		"name": "Kasungu District Hospital"
	},
	{
		"name": "Mchinji District Hospital"
	},
	{
		"name": "Nkhotakota District Hospital"
	},
	{
		"name": "Ntchisi District Hospital"
	},
	{
		"name": "Salima District Hospital"
	},
	{
		"name": "Baylor COM"
	},
	{
		"name": "Chitipa District Hospital"
	},
	{
		"name": "Karonga District Hospital"
	},
	{
		"name": "Mzimba District Hospital"
	},
	{
		"name": "Mzuzu Central Hospital"
	},
	{
		"name": "Nkhatabay District Hospital"
	},
	{
		"name": "Rumphi District Hospital"
	},
	{
		"name": "Balaka District Hospital"
	},
	{
		"name": "Chikwawa District Hospital"
	},
	{
		"name": "Chiradzulo District Hospital"
	},
	{
		"name": "Machinga District Hospital"
	},
	{
		"name": "Mulanje District Hospital"
	},
	{
		"name": "Mwanza District Hospital"
	},
	{
		"name": "Nsanje District Hospital"
	},
	{
		"name": "QECH"
	},
	{
		"name": "Thyolo District Hospital"
	},
	{
		"name": "ZCH"
	},
	{
		"name": "Kamuzu Barracks"
	},
	{
		"name": "Maula Prison"
	}
])

VisitType.create!([{name: "In Patient"}, 
                   {name: "Out Patient"},
                   {name: "Referral"}])