# frozen_string_literal: true

require_relative 'helpers/moh_report_data_migration_helpers'

# Migration that create a view name moh_report_data
class CreateMohReportDataView < ActiveRecord::Migration[7.0]
  include MohReportDataMigrationHelpers
  def up
    create_moh_report_data_view
  end

  def down
    drop_report_data_view
  end
end
