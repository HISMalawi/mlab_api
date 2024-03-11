# frozen_string_literal: true

# Tests module
module Tests
  # module for formatting test indicators presentation
  module FormatService
    class << self
      def fbc_format
        {
          "WBC": '',
          "RBC": '',
          "HGB": '',
          "HCT": '',
          "MCV": '',
          "MCH": '',
          "MCHC": '',
          "PLT": '',
          "RDW-SD": '',
          "RDW-CV": '',
          "PDW": '',
          "MPV": '',
          "PCT": '',
          "NEUT%": '',
          "LYMPH%": '',
          "MONO%": '',
          "EO%": '',
          "BASO%": '',
          "NEUT#": '',
          "LYMPH#": '',
          "MONO#": '',
          "EO#": '',
          "BASO#": '',
          "MXD#": '',
          "GRAN#": '',
          "MXD%": '',
          "GRAN%": '',
          "EOS%": '',
          "P-LCC": '',
          "P_LCR": '',
          "NRBC#": '',
          "NRBC%": '',
          "IG#": '',
          "IG%": '',
          "RET#": '',
          "RET%": '',
          "IRF": '',
          "LFR": '',
          "MFR": '',
          "HFR": '',
          "RET-HE": ''
        }
      end

      def to_array(json_object)
        json_object.values.reject(&:empty?)
      end
    end
  end
end
