# frozen_string_literal: true

# add lab location id to home reports
class AddLabLocationToHomeReports < ActiveRecord::Migration[7.0]
  def change
    add_column :home_dashboard_reports, :lab_location_id, :bigint, foreign_key: true, default: 1
  end
end
