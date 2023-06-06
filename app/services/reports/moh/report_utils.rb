# frozen_string_literal: true

# Module utils that help in generating reports
module Reports
  # Generates blood bank reports
  module Moh
    # Haematology report class
    module ReportUtils
      LOAD_PROCEDURE_YEARS_DATA = %w[
        2024 2023 2022 2021 2020 2019 2018 2017 2016 2015
      ].freeze
      HEMATOLOGY_REPORT_INDICATORS = [
        'Full Blood Count', 'Heamoglobin only (blood donors excluded)', 'Heamoglobin only (Hemacue)',
        'Patients with Hb ≤ 6.0g/dl', 'Patients with Hb ≤ 6.0g/dl who were transfused',
        'Patients with Hb > 6.0 g/dl', 'Patients with Hb > 6.0 g/dl who were transfused', 'WBC manual count',
        'Manual WBC differential', 'Erythrocyte Sedimentation Rate (ESR)', 'Sickling Test', 'Reticulocyte count',
        'Prothrombin time (PT)', 'Activated Partial Thromboplastin Time (APTT)',
        'International Normalized Ratio (INR)', 'Bleeding/ cloting time', 'CD4 absolute count', 'CD4 percentage',
        'Blood film for red cell morphology'
      ].freeze
    end
  end
end
