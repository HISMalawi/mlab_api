# frozen_string_literal: true

puts 'Clearing report cached data'
HomeDashboard.delete_all
Report.delete_all
ReportCache.delete_all
DrilldownIdentifier.delete_all
Sidekiq::ScheduledSet.new.clear
puts 'Clearing done'
