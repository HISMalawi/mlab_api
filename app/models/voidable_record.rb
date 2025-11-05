# frozen_string_literal: true

# This class is used to model a voidable record
class VoidableRecord < ApplicationRecord
  self.abstract_class = true

  include Auditable
  include Voidable

  default_scope { where(voided: 0) }
  scope :voided, -> { unscoped.where.not(voided: 0) }

  # Override destroy → void instead of delete
  def destroy(by: nil)
    run_callbacks(:destroy) do
      update_columns(
        voided: 1,
        voided_date: Time.current,
        voided_by: by || begin
          User.current&.id
        rescue StandardError
          nil
        end
      )
    end
  end

  # Restore a voided record
  def restore
    update_columns(
      voided: 0,
      voided_date: nil,
      voided_by: nil
    )
  end
end
