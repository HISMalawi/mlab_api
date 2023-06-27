module ClientManagement
  class AnalyticsService
    def get_clients_summary
      count = {}
      count['clients']= Person.count
      count['by_sex'] = Person.group(:sex).count
      count
    end
  end
end
