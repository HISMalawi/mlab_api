# frozen_string_literal: true

UnsyncOrder.where(data_not_synced: 'new order').update_all(sync_status: 0)
UnsyncOrder.where(data_not_synced: 'specimen-accepted').update_all(sync_status: 0)
UnsyncOrder.where(data_not_synced: 'specimen-rejected').update_all(sync_status: 0)
