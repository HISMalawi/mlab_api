# frozen_string_literal: true

nlims = Nlims::Sync.nlims_token
return unless nlims[:token].present? && nlims[:base_url].present?

Nlims::Sync.create_order
Nlims::Sync.update_order
Nlims::Sync.update_test
