# frozen_string_literal: true

# Machine Result model
class MachineResult < ApplicationRecord
  def self.exists_for_any_indicator?(indicator_ids, tracking_number)
    where(indicator_id: indicator_ids, tracking_number: tracking_number).exists?
  end
end
