# frozen_string_literal: true

# Gives ActiveRecord models an auditable behaviour
#
# Models with the Auditable behaviour automagically get their
# date_changed and changed_by field set to the currently logged
# in user.
#
# USAGE:
#  class ApplicationRecord < ActiveRecord::Model
#    include Auditable
#    ...
#  end
module Auditable
  extend ActiveSupport::Concern

  included do
    before_save :update_change_trail
    before_create :update_create_trail
  end

  # Saves current user after every save
  def update_change_trail
    unless respond_to?(:updated_date)
      Rails.logger.warn "Auditable model missing changed_by or date_changed: #{self}"
      return
    end
    # would be nice to have updated_by, but tour model doesn't have it

    self.updated_date = Time.now
  end

  def update_create_trail
    unless respond_to?(:created_date) && respond_to?(:creator)
      Rails.logger.warn "Auditable model missing creator or date_created: #{self}"
      return
    end
    self.creator = User.current&.id if creator.nil? || creator.zero?
    Rails.logger.warn 'Auditable::update_create_trail called outside login' unless creator

    self.created_date = Time.now
  end

  def auditable?
    respond_to?(:changed_by) && respond_to?(:updated_at)
  end
end