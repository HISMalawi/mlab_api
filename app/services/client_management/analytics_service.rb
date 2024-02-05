module ClientManagement
  class AnalyticsService
    def get_clients_summary
      count = {}
      count['clients'] = Client.count
      count['by_sex'] = Person.where(id: Client.pluck(:person_id)).group(:sex).count
      count
    end
  end
end
