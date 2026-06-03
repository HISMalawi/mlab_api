# frozen_string_literal: true

# Concern to add UUID v7 generation to models
# Usage:
#   class Order < ApplicationRecord
#     include Uuidable
#   end
module Uuidable
  extend ActiveSupport::Concern

  included do
    before_create :generate_uuid, if: -> { respond_to?(:uuid) }
  end

  private

  def generate_uuid
    self.uuid ||= UUID7.generate
  end
end
