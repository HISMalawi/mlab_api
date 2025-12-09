# frozen_string_literal: true

# UtilsService module contains utility methods used in the application
module UtilsService
  def self.age(dob)
    today = Date.today
    years_difference = today.year - dob.year
    years_difference -= 1 if (today.month < dob.month) || (today.month == dob.month && today.day < dob.day)
    years_difference += 1 if years_difference.zero?
    years_difference
  end

  def self.dob(age)
    return nil unless age.present?

    today = Date.today
    today - age.to_i.years
  end

  def self.full_sex(sex)
    return if sex.nil? || !sex.downcase.in?(%w[m f])

    sex.downcase == 'f' ? 'Female' : 'Male'
  end

  def self.insert_drilldown(entry_ids, department)
    DrilldownIdentifier.create(
      data: { associated_ids: entry_ids[:associated_ids], department: }
    )&.id
  end

  # Batch version of insert_drilldown for better performance
  def self.insert_drilldown_batch(entries_with_departments)
    return [] if entries_with_departments.empty?

    timestamp = Time.current
    user_id = User.current&.id || 1

    # Pre-generate UUIDs so we can return them
    uuids = entries_with_departments.map { SecureRandom.uuid }

    records_to_insert = entries_with_departments.map.with_index do |entry, index|
      {
        id: uuids[index],
        data: {
          associated_ids: entry[:entry_ids][:associated_ids],
          department: entry[:department]
        }.to_json,
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

  def self.detailed_age(dob)
    today = Date.today
    return '0y 0m 0w 0d' if dob.nil? || dob > today

    return '1d' if dob == today

    # Calculate the difference in years, months, and days
    years = today.year - dob.year
    months = today.month - dob.month
    days = today.day - dob.day

    # Adjust for negative days
    if days.negative?
      previous_month = today.prev_month
      days += Date.new(previous_month.year, previous_month.month, -1).day
      months -= 1
    end

    # Adjust for negative months
    if months.negative?
      months += 12
      years -= 1
    end

    # Convert remaining days to weeks and days
    weeks = days / 7
    days %= 7

    # Build the result string
    result = []
    result << "#{years}y" if years.positive?
    result << "#{months}m" if months.positive?
    result << "#{weeks}w" if weeks.positive?
    result << "#{days}d" if days.positive?

    result.join
  end
end
