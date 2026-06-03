# frozen_string_literal: true

module Reports
  module Moh
    # Base class for MOH reports with shared functionality
    class BaseReport
      protected

      def update_report_counts_optimized(counts, department)
        # Collect all drilldown data to create in batch
        drilldown_records = []

        counts.each do |count|
          month_name = count.month.downcase
          # Only process the specific indicator for this count, not all indicators
          @report[month_name][count.indicator.to_sym] = {
            count: count.total,
            associated_ids: count.associated_ids # Store the raw associated_ids temporarily
          }

          # Collect drilldown data for batch creation
          drilldown_records << {
            data: { associated_ids: count.associated_ids, department: department }
          }
        end

        # Create all drilldown identifiers in batch
        created_drilldowns = create_drilldown_identifiers_batch(drilldown_records)

        # Update the report with the created drilldown IDs
        drilldown_index = 0
        counts.each do |count|
          month_name = count.month.downcase
          @report[month_name][count.indicator.to_sym][:associated_ids] = created_drilldowns[drilldown_index]
          drilldown_index += 1
        end

        @report
      end

      def create_drilldown_identifiers_batch(drilldown_records)
        return [] if drilldown_records.empty?

        # Add timestamps and other required fields
        timestamp = Time.current
        user_id = User.current&.id || 1

        # Pre-generate UUIDs so we can return them
        uuids = drilldown_records.map { SecureRandom.uuid }

        records_to_insert = drilldown_records.map.with_index do |record, index|
          {
            id: uuids[index],
            data: record[:data].to_json,
            voided: 0,
            creator: user_id,
            created_date: timestamp,
            updated_date: timestamp
          }
        end

        # Bulk insert without returning (MySQL compatible)
        DrilldownIdentifier.insert_all(records_to_insert)

        # Return the pre-generated UUIDs
        uuids
      end
    end
  end
end
