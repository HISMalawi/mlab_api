module IblisService
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
          where m.id=#{measure_id}")
      end

      def iblis_measures
        Iblis.find_by_sql("SELECT
          m.id AS id,
          CASE
            WHEN mt.name = 'Free Text' THEN 1
            WHEN mt.name = 'Autocomplete' THEN 0
            WHEN mt.name = 'Alphanumeric Values' THEN 0
            WHEN mt.name = 'Rich Text' THEN 4
            ELSE 2
          END AS test_indicator_type,
          m.name AS name,
          m.unit AS unit,
          m.description AS description,
          m.created_at AS created_date,
          m.updated_at AS updated_date,
          CASE
            WHEN m.deleted_at IS NULL THEN 0
            ELSE 1
          END AS retired,
          CASE
            WHEN m.deleted_at IS NULL THEN NULL
            ELSE m.deleted_at
          END AS retired_date,
          1 AS creator
          FROM
            measures m
                INNER JOIN
            measure_types mt ON mt.id = m.measure_type_id
        ")
      end

      def create_test_type_test_indicator_mapping
        iblis_measures_test_types = Iblis.find_by_sql("SELECT
            test_type_id AS test_types_id, measure_id AS test_indicators_id,
            0 AS voided, now() AS created_date, now() AS updated_date
            FROM testtype_measures")
        return if iblis_measures_test_types.empty?

        TestTypeTestIndicator.upsert_all(iblis_measures_test_types.map(&:attributes), returning: false)
      end

      def create_test_indicator
        measures = iblis_measures
        measures.each do |measure|
          test_indicator = TestIndicator.find_or_create_by(id: measure.id, name: measure.name,
                                                           test_indicator_type: measure.test_indicator_type,
                                                           unit: measure.unit, description: measure.description,
                                                           retired: measure.retired,
                                                           creator: measure.creator, created_date: measure.created_date,
                                                           updated_date: measure.updated_date)
          create_test_indicator_range(measure.id, measure.test_indicator_type, test_indicator.id)
        rescue StandardError => e
          Rails.logger.info("=========Error Loading Test Indicator: #{e}===========")
        end
      end

      def create_test_indicator_range(iblis_measure_id, test_indicator_type, test_indicator_id)
        iblis_measure_ranges = iblis_measure_ranges(iblis_measure_id)
        if [TestCatalog::TestTypes::TestIndicatorType::AUTO_COMPLETE,
            TestCatalog::TestTypes::TestIndicatorType::ALPANUMERIC].include? test_indicator_type
          iblis_measure_ranges.each do |measure_range|
            res = create_test_indicator_range_for_autocomplete(measure_range, test_indicator_id)
            void_indicator_ranges(res, measure_range.mr_deleted_at) unless measure_range.mr_deleted_at.nil?
          end
        elsif test_indicator_type == TestCatalog::TestTypes::TestIndicatorType::NUMERIC
          iblis_measure_ranges.each do |measure_range|
            res = create_test_indicator_range_for_numeric(measure_range, test_indicator_id)
            void_indicator_ranges(res, measure_range.mr_deleted_at) unless measure_range.mr_deleted_at.nil?
          end
        end
      end

      def create_test_indicator_range_for_autocomplete(indicator_range, test_indicator_id)
        TestIndicatorRange.create!(test_indicator_id:, value: indicator_range.mr_value,
                                   interpretation: indicator_range.mr_interpretation, retired: 0,
                                   creator: 1, created_date: indicator_range.m_created_at,
                                   updated_date: indicator_range.m_updated_at)
      end

      def create_test_indicator_range_for_numeric(indicator_range, test_indicator_id)
        TestIndicatorRange.create!(test_indicator_id:, min_age: indicator_range.mr_min_age,
                                   max_age: indicator_range.mr_max_age,
                                   interpretation: indicator_range.mr_interpretation,
                                   retired: 0, sex: indicator_range.mr_gender,
                                   lower_range: indicator_range.mr_lower_range,
                                   upper_range: indicator_range.mr_upper_range,
                                   creator: 1, created_date: indicator_range.m_created_at,
                                   updated_date: indicator_range.m_updated_at)
      end

      def void_indicator_ranges(range, deleted_at)
        range.update!(retired: 1, retired_by: 1, retired_date: deleted_at, retired_reason: 'deleted',
                      updated_date: deleted_at)
      end
    end
  end
end
