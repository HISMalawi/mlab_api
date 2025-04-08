# frozen_string_literal: true

# Model for post cross match process
class PostCrossmatchProcess < VoidableRecord
  before_create :set_collection_date
  before_create :set_returned_detail

  def set_collection_date
    self.collection_date ||= Time.now
  end

  def set_returned_detail
    return unless returned

    self.returned_date ||= Time.now
  end
end
