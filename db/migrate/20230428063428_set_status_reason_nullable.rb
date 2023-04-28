class SetStatusReasonNullable < ActiveRecord::Migration[7.0]
  def change
    change_column :test_statuses, :status_reason_id, :bigint, null: true
  end
end
