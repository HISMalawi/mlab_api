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
end
