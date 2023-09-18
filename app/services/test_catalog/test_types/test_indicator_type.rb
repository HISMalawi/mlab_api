# frozen_string_literal: true

# module TestCatalog
module TestCatalog
  # module TestTypes
  module TestTypes
    # module TestIndicatorType
    module TestIndicatorType
      AUTO_COMPLETE = 0
      FREE_TEXT = 1
      NUMERIC = 2
      ALPANUMERIC = 3
      RICH_TEXT = 4

      class << self
        def show_test_indicator_types
          types = []
          indicator_types = TestIndicator.test_indicator_types
          indicator_types.each do |key, value|
            data = {
              id: value,
              name: key.gsub('_', ' ').titleize
            }
            types << data
          end
          types
        end
      end
    end
  end
end
