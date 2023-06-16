class ChangeEncountersForeignKey < ActiveRecord::Migration[7.0]
  def change
    change_column_null :encounters, :facility_section_id, true
    change_column_null :encounters, :destination_id, true
    change_column_null :encounters, :facility_id, true
  end
end
