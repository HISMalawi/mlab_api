# frozen_string_literal: true

# HomeDashboard model
class HomeDashboard < VoidableRecord
  self.table_name = 'home_dashboard_reports'
  default_scope { where('updated_date >= ?', 3.hours.ago) }
end
