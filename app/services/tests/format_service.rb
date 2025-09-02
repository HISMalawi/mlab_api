# frozen_string_literal: true

# Tests module
module Tests
  # module for formatting test indicators presentation
  module FormatService
    class << self
      def fbc_format
        {
          'White Blood Cell' => '',
          'Red Blood Cell' => '',
          'Haemoglobin' => '',
          'Hematocrit' => '',
          'Mean Corpuscular Volume' => '',
          'Mean Corpuscular Hemoglobin' => '',
          'Mean Corpuscular Hemoglobin Concentration' => '',
          'Platelet Count' => '',
          'Red Cell Distribution Width – Standard Deviation' => '',
          'Red Cell Distribution Width – Coefficient of Variation' => '',
          'Platelet Distribution Width' => '',
          'Mean Platelet Volume' => '',
          'Plateletcrit' => '',
          'Neutrophil Percentage' => '',
          'Lymphocyte Percentage' => '',
          'Monocyte Percentage' => '',
          'Eosinophil Percentage' => '',
          'Basophil Percentage' => '',
          'Absolute Neutrophil Count' => '',
          'Absolute Lymphocyte Count' => '',
          'Absolute Monocyte Count' => '',
          'Absolute Eosinophil Count' => '',
          'Absolute Basophil Count' => '',
          'Platelet Large Cell Count' => '',
          'Platelet Large Cell Ratio' => '',
          'Reticulocyte Percentage' => '',
          'Absolute Reticulocyte Count' => '',
          'Nucleated Red Blood Cells Percentage' => '',
          'Absolute Nucleated Red Blood Cell Count' => '',
          'Absolute Middle Cell Population Count' => '',
          'Middle Cell Population Percentage' => '',
          'Granulocyte Percentage' => '',
          'Absolute Granulocyte Count' => ''
        }.transform_keys(&:upcase)
      end

      def to_array(json_object)
        json_object.values.reject(&:empty?)
      end
    end
  end
end
