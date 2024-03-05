# frozen_string_literal: true

# Home Dashboard report migration
class CreateHomeDashboardReport < ActiveRecord::Migration[7.0]
  def change
    create_table :home_dashboard_reports do |t|
      t.string :report_type, null: false
      t.string :department, default: 'All', null: false
      t.json :data
      t.integer :voided
      t.bigint :voided_by
      t.datetime :created_date, null: false, default: Time.now
      t.datetime :updated_date, null: false, default: Time.now
      t.bigint :updated_by, null: true
    end
  end
end
