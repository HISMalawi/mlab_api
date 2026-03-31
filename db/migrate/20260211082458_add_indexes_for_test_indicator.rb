class AddIndexesForTestIndicator < ActiveRecord::Migration[7.0]
  def change
    # 1. For joining test_results -> test_indicators (r)
    unless index_exists?(:test_results, :test_indicator_id, name: :idx_test_results_on_test_indicator_id)
      add_index :test_results,
                :test_indicator_id,
                name: :idx_test_results_on_test_indicator_id
    end

    # 2. For filtering test results by test_indicator_id and voided
    unless index_exists?(:test_results, %i[test_indicator_id voided],
                         name: :idx_test_results_on_test_indicator_id_and_voided)
      add_index :test_results,
                %i[test_indicator_id voided],
                name: :idx_test_results_on_test_indicator_id_and_voided
    end

    # 3. For filtering retired indicators by name
    unless index_exists?(:test_indicators, %i[name retired], name: :idx_test_indicators_on_name_and_retired)
      add_index :test_indicators,
                %i[name retired],
                name: :idx_test_indicators_on_name_and_retired
    end

    unless index_exists?(:test_results, %i[voided], name: :idx_test_results_on_voided)
      add_index :test_results,
                %i[voided],
                name: :idx_test_results_on_voided
    end

    # 4. Optional but helpful when filtering by retired during joins
    return if index_exists?(:test_indicators, %i[id retired], name: :idx_test_indicators_on_id_and_retired)

    add_index :test_indicators,
              %i[id retired],
              name: :idx_test_indicators_on_id_and_retired
  end
end
