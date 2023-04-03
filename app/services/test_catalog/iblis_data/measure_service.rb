module TestCatalog
  module IblisData
    module MeasureService
      class << self
        def iblis_measure_ranges(measure_id)
          Iblis.find_by_sql("SELECT 
            mr.age_min AS mr_min_age,
            mr.age_max AS mr_max_age,
            (CASE mr.gender
              WHEN '0' THEN 'Male'
              WHEN '1' THEN 'Female'
              WHEN '2' THEN 'Both'
              ELSE NULL
            END) AS mr_gender,
            mr.range_lower AS mr_lower_range,
            mr.range_upper as mr_upper_range,
            mr.alphanumeric AS mr_value,
            mr.interpretation as mr_interpretation,
            m.created_at AS m_created_at,
            m.updated_at AS m_updated_at,
            mr.deleted_at AS mr_deleted_at
            FROM
            measures m
                INNER JOIN
            testtype_measures tm ON tm.measure_id = m.id
                INNER JOIN
            test_types tt ON tt.id = tm.test_type_id
                INNER JOIN
            measure_ranges mr ON mr.measure_id = m.id
                INNER JOIN
            measure_types mt ON mt.id=m.measure_type_id
            where m.id=#{measure_id}"
          )
        end
      
        def iblis_measures(test_type_id)
          Iblis.find_by_sql("SELECT 
            m.id AS m_id,
            tm.test_type_id,
            mt.name AS m_measure_type,
            m.name AS m_name,
            m.unit AS m_unit,
            m.description AS m_description,
            m.created_at AS m_created_at,
            m.updated_at AS m_updated_at,
            m.deleted_at AS m_deleted_at
            FROM
              measures m
                  INNER JOIN
              testtype_measures tm ON tm.measure_id = m.id
                  INNER JOIN
              measure_types mt ON mt.id = m.measure_type_id
            WHERE
              tm.test_type_id = #{test_type_id}
          ")
        end
    
        def create_test_indicator(iblis_test_type_id, mlap_test_type_id)
          iblis_measures = iblis_measures(iblis_test_type_id)
          iblis_measures.each do |measure|
            test_indicator_type = indicator_type(measure.m_measure_type)
            iblis_measure_ranges = iblis_measure_ranges(measure.m_id)
            if measure.m_deleted_at.nil?
              test_indicator = TestIndicator.new(name: measure.m_name, test_type_id: mlap_test_type_id, test_indicator_type: test_indicator_type, 
                unit: measure.m_unit, description: measure.m_description, retired: 0, creator: 1, created_date: measure.m_created_at, updated_date: measure.m_updated_at)
              if test_indicator.save
                create_test_indicator_range(measure.m_id, test_indicator_type, test_indicator.id)
              end 
            else
              test_indicator = TestIndicator.new(name: measure.m_name, test_type_id: mlap_test_type_id, test_indicator_type: test_indicator_type, 
                unit: measure.m_unit, description: measure.m_description, retired: 1, retired_by: 1, retired_reason: 'Removed', retired_date: measure.m_deleted_at, creator: 1, created_date: measure.m_created_at, updated_date: measure.m_updated_at)
            end
          end
        end
    
        def indicator_type(measure_type)
          test_indicator_type = ''
          if measure_type == 'Free Text'
            test_indicator_type = 1
          elsif measure_type == 'Autocomplete'
            test_indicator_type = 0
          elsif measure_type == 'Alphanumeric Values'
            test_indicator_type = 3
          else 
            test_indicator_type = 2
          end
          test_indicator_type
        end
    
        def create_test_indicator_range(iblis_measure_id, test_indicator_type, test_indicator_id)
          iblis_measure_ranges = iblis_measure_ranges(iblis_measure_id)
          if [TestCatalog::TestTypes::TestIndicatorType::AUTO_COMPLETE, TestCatalog::TestTypes::TestIndicatorType::ALPANUMERIC].include? test_indicator_type
            iblis_measure_ranges.each do |measure_range|
              res = create_test_indicator_range_for_autocomplete(measure_range, test_indicator_id)
              if !measure_range.mr_deleted_at.nil?
                void_indicator_ranges(res, measure_range.mr_deleted_at)
              end
            end
          elsif test_indicator_type ==  TestCatalog::TestTypes::TestIndicatorType::NUMERIC
            iblis_measure_ranges.each do |measure_range|
              res = create_test_indicator_range_for_numeric(measure_range, test_indicator_id)
              if !measure_range.mr_deleted_at.nil?
                void_indicator_ranges(res, measure_range.mr_deleted_at)
              end
            end
          end
        end
    
        def create_test_indicator_range_for_autocomplete(indicator_range, test_indicator_id)
          TestIndicatorRange.create!(test_indicator_id: test_indicator_id, value: indicator_range.mr_value, interpretation: indicator_range.mr_interpretation, retired: 0, 
            creator: 1, created_date: indicator_range.m_created_at, updated_date: indicator_range.m_updated_at)
        end
    
        def create_test_indicator_range_for_numeric(indicator_range, test_indicator_id)
          TestIndicatorRange.create!(test_indicator_id: test_indicator_id, min_age: indicator_range.mr_min_age, max_age: indicator_range.mr_max_age, interpretation: indicator_range.mr_interpretation, 
            retired: 0, sex: indicator_range.mr_gender, lower_range: indicator_range.mr_lower_range, upper_range: indicator_range.mr_upper_range, creator: 1, created_date: indicator_range.m_created_at, updated_date: indicator_range.m_updated_at)
        end
    
        def void_indicator_ranges(range, deleted_at)
          range.update(retired: 1, retired_by: 1, retired_date: deleted_at, retired_reason: 'deleted', updated_date: deleted_at)
        end
    
      end
    
    end
  end
end