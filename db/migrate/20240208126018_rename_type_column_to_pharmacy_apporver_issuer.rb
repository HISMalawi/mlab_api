# frozen_string_literal: true

# Migration for PharmacyApporverIssuer
class RenameTypeColumnToPharmacyApporverIssuer < ActiveRecord::Migration[7.0]
  def change
    rename_column :stock_pharmacy_approver_and_issuers, :type, :record_type
  end
end
