module Tests
    class TestService

        def find_tests(query, department_id=nil)
            tests = Test.joins(:test_type, order: [encounter: [client: [:person]]])
            tests = tests.where("test_types.name LIKE ? or test_types.short_name LIKE ?", "%#{query}%", "%#{query}%") if query.present?
            tests = search_by_accession_number(tests, query) if query.present?
            tests = search_by_client(tests, query) if query.present?
            tests = tests.where(test_type_id: TestType.where(department_id: department_id).pluck(:id)) if department_id.present? && is_not_reception?(department_id)
            tests.order('orders.id DESC')
        end


        private

            def is_not_reception?(department_id)
                Department.find(department_id).name != 'Lab Reception'
            end

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