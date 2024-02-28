# frozen_string_literal: true

# Remark model
class Remark < VoidableRecord
  def as_json(options = {})
    super(options.merge({only: %i[id tests_id value]}))
  end
end
