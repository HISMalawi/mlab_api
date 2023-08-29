# frozen_string_literal: true

# Migration for PharmacyApporverIssuer
class AddTypeColumnToPharmacyApporverIssuer < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_pharmacy_approver_and_issuers, :type, :string
  end
end
