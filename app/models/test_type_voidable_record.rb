# frozen_string_literal: true

# This class is used to model a voidable record
class TestTypeVoidableRecord < ApplicationRecord
  self.abstract_class = true

  include Auditable
  include Voidable

  default_scope { where(retired: 0) }
  scope :retired, -> { unscoped.where.not(retired: 0) }
  scope :active_without_paediatric_cancer, lambda {
    where.not("name LIKE '%(Paed%'")
         .where.not("name LIKE '%(cancer%'")
  }

  belongs_to :creator_user, foreign_key: 'creator', class_name: 'User', optional: true

  def void(*args, **kwargs)
    # HACK: This should normally be called within the top most scope of
    # a class but we are calling it here as it seems not work through
    # more than 1 level of inheritance.
    self.class.remap_voidable_interface(
      voided: :retired, voided_date: :retired_date,
      voided_reason: :retired_reason, voided_by: :retired_by
    )

    super(*args, **kwargs)
  end
end
