# frozen_string_literal: true

# Module Reports
module Reports
  # Daily reports module
  module DailyReport
    # Service for generating the Blood Donor Register report.
    #
    # Ported from the legacy iBLIS report
    # (app/views/reports/blooddonorregister/index.blade.php +
    #  ReportController@bloodDonorRegister). It lists the most recent "Blood Donor
    # Test" tests together with the donor demographics and the individual result
    # values (blood group, Hb, HIV, Hep C, Hep B, Syphilis, Malaria, donation
    # status).
    module BloodDonorRegister
      # Names a "Blood Donor" test type might be registered under.
      TEST_TYPE_NAMES = ['Blood Donor Test', 'Blood Donor', 'Blood Donor Register', 'Blood Donation',
                         'Blood Donor Screening'].freeze

      DEFAULT_LIMIT = 100
      MAX_LIMIT = 500

      # column key => [exact lowercase indicator names, fallback regex]
      RESULT_COLUMNS = {
        blood_group: [['blood group', 'abo group', 'grouping', 'abo/rh group'],
                      /blood\s*group|abo|grouping|rh\s*group/i],
        hb: [['hb', 'hb(g/dl)', 'haemoglobin', 'hemoglobin'], /\A(hb|hgb)\z|haemoglobin|hemoglobin/i],
        hiv: [['hiv'], /hiv/i],
        hep_c: [['hep c', 'hepatitis c', 'hcv'], /hep(atitis)?\s*-?\s*c\b|\bhcv\b|anti-?hcv/i],
        hep_b: [['hep b', 'hepatitis b', 'hbsag'], /hep(atitis)?\s*-?\s*b\b|\bhbs?ag\b|\bhbv\b/i],
        syphilis: [%w[syphilis vdrl rpr tpha], /syphilis|vdrl|\brpr\b|\btpha\b/i],
        malaria: [['malaria', 'mrdt', 'mps', 'malaria rapid diagnostic test'], /malaria|\bmrdt\b|\bmps\b/i],
        donation_status: [['donation status', 'donor status', 'fitness to donate'],
                          /donation\s*status|donor\s*status|fit(ness)?\s*to\s*donate/i]
      }.freeze

      class << self
        # options: :search, :from, :to, :limit
        def generate_report(options = {})
          search = options[:search].to_s.strip
          from = options[:from]
          to = options[:to]
          limit = sanitize_limit(options[:limit])

          test_type_ids = blood_donor_test_type_ids
          if test_type_ids.empty?
            return { from:, to:, search:, test_type: TEST_TYPE_NAMES.first, count: 0, data: [],
                     message: 'No "Blood Donor Test" test type is configured on this facility.' }
          end

          rows = base_rows(test_type_ids, search, from, to, limit)
          test_ids = rows.map { |r| r['test_id'] }
          client_ids = rows.map { |r| r['client_id'] }

          results_by_test = results_by_test(test_ids)
          address_by_client = address_by_client(client_ids)

          data = rows.map do |r|
            results = results_by_test[r['test_id']] || {}
            {
              test_id: r['test_id'],
              date: r['test_date'],
              accession_number: r['accession_number'],
              name: r['donor_name'].to_s.strip,
              age: age(r['dob']),
              sex: sex(r['sex']),
              address: address_by_client[r['client_id']],
              specimen: r['specimen'],
              blood_group: pick(results, :blood_group),
              hb: pick(results, :hb),
              hiv: pick(results, :hiv),
              hep_c: pick(results, :hep_c),
              hep_b: pick(results, :hep_b),
              syphilis: pick(results, :syphilis),
              malaria: pick(results, :malaria),
              donation_status: pick(results, :donation_status),
              results: results
            }
          end

          { from:, to:, search:, test_type: resolved_test_type_names(test_type_ids), count: data.length, data: }
        end

        private

        def sanitize_limit(value)
          limit = value.to_i
          return DEFAULT_LIMIT if limit <= 0

          [limit, MAX_LIMIT].min
        end

        def blood_donor_test_type_ids
          TestType.where(name: TEST_TYPE_NAMES)
                  .or(TestType.where(preferred_name: TEST_TYPE_NAMES))
                  .pluck(:id)
        end

        def resolved_test_type_names(ids)
          TestType.where(id: ids).pluck(:name).uniq.join(', ')
        end

        def base_rows(test_type_ids, search, from, to, limit)
          date_condition = ''
          if from.present? && to.present?
            date_condition = " AND t.created_date BETWEEN #{quote(from.to_date.beginning_of_day)} " \
                             "AND #{quote(to.to_date.end_of_day)} "
          end

          search_condition = ''
          if search.present?
            like = quote("%#{search}%")
            search_condition = " AND (o.accession_number LIKE #{like} " \
                               "OR CONCAT(p.first_name, ' ', p.last_name) LIKE #{like}) "
          end

          Report.find_by_sql(<<~SQL).map(&:attributes)
            SELECT
                t.id                                        AS test_id,
                t.created_date                              AS test_date,
                o.accession_number                          AS accession_number,
                c.id                                        AS client_id,
                CONCAT(p.first_name, ' ', p.last_name)       AS donor_name,
                p.date_of_birth                             AS dob,
                p.sex                                       AS sex,
                s.name                                      AS specimen
            FROM tests t
                JOIN orders o        ON o.id = t.order_id
                JOIN encounters e    ON e.id = o.encounter_id
                JOIN clients c       ON c.id = e.client_id
                JOIN people p        ON p.id = c.person_id
                JOIN test_types tt   ON tt.id = t.test_type_id
                LEFT JOIN specimen s ON s.id = t.specimen_id
            WHERE t.voided = 0
                AND tt.id IN (#{test_type_ids.join(',')})
                #{date_condition}
                #{search_condition}
            ORDER BY t.created_date DESC
            LIMIT #{limit}
          SQL
        end

        # { test_id => { "indicator name (downcased)" => value } }
        def results_by_test(test_ids)
          return {} if test_ids.blank?

          hash = Hash.new { |h, k| h[k] = {} }
          TestResult
            .where(test_id: test_ids, voided: 0)
            .joins('JOIN test_indicators ti ON ti.id = test_results.test_indicator_id')
            .pluck(:test_id, Arel.sql("COALESCE(NULLIF(ti.name, ''), ti.preferred_name, ti.short_name)"), :value)
            .each do |test_id, indicator_name, value|
              next if indicator_name.blank?

              hash[test_id][indicator_name.to_s.downcase.strip] = value
            end
          hash
        end

        # { client_id => "composed address" }
        def address_by_client(client_ids)
          return {} if client_ids.blank?

          grouped = Hash.new { |h, k| h[k] = {} }
          ClientIdentifier
            .where(client_id: client_ids, voided: 0)
            .joins(:client_identifier_type)
            .pluck(:client_id, Arel.sql('client_identifier_types.name'), :value)
            .each do |client_id, type, value|
              grouped[client_id][type] = value if value.present?
            end

          grouped.transform_values { |identifiers| compose_address(identifiers) }
        end

        def compose_address(identifiers)
          return identifiers['physical_address'] if identifiers['physical_address'].present?

          %w[current_village current_traditional_authority current_district home_village home_district]
            .filter_map { |key| identifiers[key] }
            .uniq
            .join(', ')
            .presence
        end

        def pick(results, column)
          exact_keys, regex = RESULT_COLUMNS[column]
          exact_keys.each { |key| return results[key] if results.key?(key) }
          match = results.find { |name, _| name.match?(regex) }
          match&.last
        end

        def age(dob)
          return nil if dob.blank?

          UtilsService.age(dob.to_date)
        rescue StandardError
          nil
        end

        def sex(value)
          return '' if value.blank?

          value.to_s.upcase.start_with?('F') ? 'F' : 'M'
        end

        def quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end
