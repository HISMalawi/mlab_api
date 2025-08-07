# frozen_string_literal: true

# Model for pack number logs
class PackNumberLog < VoidableRecord
  belongs_to :test
  before_create :set_suffix

  def set_suffix
    self.suffix ||= generate_suffix
  end

  def generate_suffix(pack_number = self.pack_number)
    last_pack = self.class.where(pack_number:).order(:created_date).last
    return 'A' if last_pack.nil?

    return 'A' if last_pack.suffix.nil?

    last_pack.suffix.next
  end

  def self.pack_number_exist?(pack_number)
    where(pack_number:).exists?
  end

  def self.next_pack_number_suffix(pack_number)
    last_pack = where(pack_number:).order(:created_date).last
    last_pack.nil? ? 'A' : last_pack.suffix.next
  end
end
