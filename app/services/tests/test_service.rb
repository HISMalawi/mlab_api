module Tests
    class TestService

        def find_tests(query)
            tests = Test.joins(:test_type, order: [encounter: [client: [:person]]])
            tests = tests.where("test_types.name LIKE ? or test_types.short_name LIKE ?", "%#{query}%", "%#{query}%") if query.present?
            tests = search_by_accession_number(tests, query) if query.present?
            tests = search_by_client(tests, query) if query.present?
            tests.order('orders.id DESC')
        end


        private

            def search_by_accession_number(tests,query)
                tests.or(Test.where("orders.accession_number LIKE ?", "%#{query}%"))
            end
            
            def search_by_client(tests,query)
                clients = client_service.search_client(query, 1000)
                return tests unless clients.present?
                tests.or(Test.where("clients.id IN (?)", clients.map(&:id))) if clients.present? 
            end

            def client_service
                ClientManagement::ClientService
            end
    end
end