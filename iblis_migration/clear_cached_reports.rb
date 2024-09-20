# frozen_string_literal: true

puts 'Clearing report cached data'
HomeDashboard.delete_all
Report.delete_all
ReportCache.delete_all
puts 'Clearing done'
