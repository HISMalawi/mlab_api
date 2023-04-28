class EncounterType < VoidableRecord
  self.primary_key = 'id'
  validates_presence_of :name
end
