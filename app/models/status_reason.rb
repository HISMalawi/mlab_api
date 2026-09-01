class StatusReason < RetirableRecord
  validates :description, uniqueness: true, presence: true

  # Resolve a free-text reason (entered by a user via the "Other" option) to a
  # StatusReason record, creating it when no matching (non-retired) reason
  # exists. Matching is case-insensitive and ignores surrounding whitespace.
  def self.for_description(description)
    description = description.to_s.strip
    return nil if description.blank?

    find_by('LOWER(description) = LOWER(?)', description) || create!(description:)
  end
end
