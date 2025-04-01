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

  def self.full_sex(sex)
    return if sex.nil? || !sex.downcase.in?(%w[m f])

    sex.downcase == 'f' ? 'Female' : 'Male'
  end

  def self.insert_drilldown(entry_ids, department)
    DrilldownIdentifier.create(
      data: { associated_ids: entry_ids[:associated_ids], department: }
    )&.id
  end

  def self.detailed_age(dob)
    today = Date.today
    return '0y 0m 0w 0d' if dob.nil? || dob > today

    return '1d' if dob == today

    # Calculate the difference in years, months, and days
    years = today.year - dob.year
    years -= 1 if (today.month < dob.month) || (today.month == dob.month && today.day < dob.day)

    months = today.month - dob.month
    months += 12 if months.negative?
    months -= 1 if today.day < dob.day

    # Calculate remaining days in the current month
    days_in_month = (dob >> (years * 12 + months)).next_month.prev_day.day
    days = today.day - dob.day
    days += days_in_month if days.negative?

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
