# frozen_string_literal: true

# AccessionNumberTracker model
class AccessionNumberTracker < VoidableRecord
  validates_uniqueness_of :accession_number
end
