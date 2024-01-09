# frozen_string_literal: true

# Module utils that help in generating reports
module Reports
  # Generates blood bank reports
  module Moh
    # Haematology report class
    module ReportUtils
      class << self
        def report_years
          range = []
          max_year = Test.maximum(:created_date)
          unless max_year.nil?
            min_year = Test.minimum(:created_date).year
            range = (min_year.to_s..max_year.year.to_s).to_a
          end
          range
        end

        def check_if_file_exists(department, year)
          file_path = Rails.root.join('public', "#{department}_#{year}_moh_report_data.json")
          File.exist?(file_path) ? true : false
        end

        def get_file_path(department, year)
          Rails.root.join('public', "#{department}_#{year}_moh_report_data.json")
        end

        def save_report_to_json(department, data, year)
          file_path = Rails.root.join('public', "#{department}_#{year}_moh_report_data.json")
          File.open(file_path, 'w') do |file|
            file.write(JSON.generate(data))
          end
        end

        def test_type_ids(actual_name)
          manual_names = NameMapping.where(actual_name:).map(&:manual_name)
          ids = TestType.where(name: manual_names).map(&:id)
          "(#{ids.join(', ')})"
        end

        def test_indicator_ids(actual_name)
          manual_names = NameMapping.where(actual_name:).map(&:manual_name)
          ids = TestIndicator.where(name: manual_names).map(&:id)
          "(#{ids.join(', ')})"
        end
      end
    end
  end
end
