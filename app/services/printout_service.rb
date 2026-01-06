module PrintoutService
  class << self
    def print_accession_number(person, order)
      barcode_label(person, order).print(2)
    end

    def print_tracking_number(person, order)
      barcode_label(person, order, false).print(2)
    end

    def barcode_label(person, order, is_accession_number = true)
      tests = order.tests.map do |test_|
        test_name = if test_.short_name.blank?
                      GlobalService.display_name(test_.test_type.name, test_.test_type.preferred_name)
                    else
                      test_.short_name
                    end
        test_.method_of_testing.nil? ? test_name : "#{test_name}(#{test_.method_of_testing})"
      end
      priority = order&.priority&.name
      priority = priority.downcase == 'stat' ? " #{priority}  " : priority
      data = is_accession_number ? order.accession_number.scan(/\d+/).first.to_i : order.tracking_number
      f_number = is_accession_number ? order.accession_number : order.tracking_number
      label = ZebraPrinter::Label.new(801, 329, 'T', nil, true)
      # left_align_from = 40
      client_details = "#{person.fullname} #{person.sex}"
      label.draw_text(client_details, 40, 3, 0, 2, 1, 1)
      label.draw_text(
        "DoB:#{person.date_of_birth.strftime('%d-%b-%Y')} Age:#{UtilsService.detailed_age(person.date_of_birth)}", 40, 22, 0, 2, 1, 1
      )
      label.draw_barcode(51, 41, 0, '1A', 2, 2, 50, false, data)
      label.draw_text("#{f_number} * #{data}", 51, 100, 0, 2, 1, 1)
      label.draw_text(
        "Col: #{order.created_date.strftime('%d/%b/%Y %H:%M')} #{User.find(order.creator).username}",
        40, 122, 0, 2, 1, 1
      )
      label.draw_text(tests.uniq.join(','), 40, 149, 0, 2, 1, 1)
      label.draw_text(priority.to_s, 30, 3, 1, 2, 1, 2, 'R')
      label
    end

    def print_zebra_report(person, order, test_ids, is_cross_match)
      accession_number = order.accession_number
      patient = person.fullname
      date = Date.today.strftime
      ward = order.encounter&.facility_section&.name
      by = User.where(id: TestStatus.where(test_id: Test.where(order_id: order.id),
                                           status_id: 4).first&.creator).first&.person&.fullname
      pack_abo_group = ''
      post_crossmatch_process = []
      test_results = TestResult.joins(:test_indicator).where(test_id: test_ids)
                               .select(
                                 'test_results.id,
                                test_indicators.id AS test_indicator_id,
                                test_indicators.name,
                                test_indicators.preferred_name,
                                test_results.value'
                               )

      if is_cross_match
        test_id = Test.where(order_id: order.id)
        post_crossmatch_process = PostCrossmatchProcess.joins(:facility_section).where(test_id:).select(
          'collected_by',
          'facility_sections.name AS to_ward',
          'collection_date',
          'transfusion_outcome',
          'returned',
          'returned_by',
          'returned_date',
          'returned_reason'
        )&.first || post_crossmatch_process
        pack_abo_group = TestResult.where(
          test_id:,
          test_indicator_id: TestIndicator.where(name: 'Grouping').pluck('id')
        ).first&.value
      end
      is_collected = post_crossmatch_process.present?
      if is_collected
        post_crossmatch_process = post_crossmatch_process.attributes.map do |key, value|
          if key.include?('date')
            {
              name: key.to_s.gsub('_', ' ').split.map(&:capitalize).join(' '),
              value: value.present? ? value.strftime('%Y-%m-%d %H:%M') : nil,
              unit: nil
            }
          else
            { name: key.to_s.gsub('_', ' ').split.map(&:capitalize).join(' '), value:, unit: nil }
          end
        end
      end
      test_result_records = test_results.map do |test_result|
        {
          name: GlobalService.display_name(test_result.name, test_result.preferred_name),
          value: test_result.value,
          unit: TestTypeTestIndicator.find_by(test_indicators_id: test_result.test_indicator_id)&.unit
        }
      end
      test_results = (test_result_records + post_crossmatch_process).select do |test_result|
        !test_result[:value].nil?
      end

      z_label = ZebraPrinter::Label.new
      z_label.line_spacing = 1
      left_align_from = 20
      col_width = 200
      padding = 15 # Define the padding value

      ## ─────────────────────────── HEADER ───────────────────────────
      header_y = 2 # Y-position for header lines

      z_label.draw_text("Accession No: #{accession_number}", left_align_from, header_y, 0, 1, 1, 2)
      z_label.draw_text("Print Date: #{date}", left_align_from + 570, header_y, 0, 1, 1, 2)

      z_label.draw_text("Patient: #{patient}", left_align_from, header_y + 28, 0, 1, 1, 2)
      z_label.draw_text("Ward: #{ward}", left_align_from + 290, header_y + 28, 0, 1, 1, 2)
      z_label.draw_text("By: #{by}", left_align_from + 540, header_y + 28, 0, 1, 1, 2)

      unless pack_abo_group.blank?
        z_label.draw_text("ABO Group: #{pack_abo_group}", left_align_from + 290, header_y, 0, 1, 1, 2)
      end
      z_label.draw_text("Date Registered: #{order.created_date.to_date}", left_align_from, header_y + 56, 0, 1, 1, 2)

      # ─────────────────────────── SPACE AFTER HEADER ───────────────────────────
      table_start_y = header_y + 120 # Ensure space before the table starts

      ## ─────────────────────────── TABLE ───────────────────────────
      vertical_pos_reduct_by = 30
      results_per_row = 2 # Two result columns per row

      test_results.each_slice(results_per_row).with_index do |test_group, row_index|
        test_group.each_with_index do |test_result, col_index|
          next if test_result[:value].blank?

          # Apply padding to result names & values
          name_x_pos = left_align_from + padding + (col_width * col_index * 2)
          value_x_pos = name_x_pos + col_width
          y_pos = table_start_y + (row_index * 25) - vertical_pos_reduct_by

          value = "#{test_result[:value] || ''} #{test_result[:unit] || ''}"
          result_value = value.present? ? value.to_s : 'N/A'
          z_label.draw_text(test_result[:name].to_s[0, 18].strip, name_x_pos - 6, y_pos + 3, 0, 1, 1, 2)
          z_label.draw_text(result_value.strip, value_x_pos - 6, y_pos + 3, 0, 1, 1, 2)
        end
      end

      ## ─────────────────────────── DRAW LINES ───────────────────────────
      test_result_size = test_results.size.odd? ? test_results.size + 1 : test_results.size
      last_y_post = table_start_y + ((test_result_size / results_per_row.to_f).ceil * 25) - vertical_pos_reduct_by
      ((test_result_size / 2) + 1).times do |i|
        y_pos = table_start_y + (i * 25) - vertical_pos_reduct_by
        z_label.draw_line(left_align_from, y_pos, 760, 2)
      end
      unless is_collected
        z_label.draw_barcode(
          100, last_y_post + 10, 0, '1A', 2, 2, 50, false, order.accession_number.scan(/\d+/).first.to_i
        )
      end

      # Vertical lines for columns
      4.times do |i|
        x_pos = (left_align_from + (col_width * i) + padding) - 15
        z_label.draw_line(x_pos, table_start_y - vertical_pos_reduct_by, 1,
                          (test_result_size / results_per_row.to_f).ceil * 27)
      end

      ## ─────────────────────────── PRINT LABEL ───────────────────────────
      z_label.print(1)
    end

    def print_patient_report(uploaded_file, printer_name, directory_name, order_ids)
      print_job = a4_printing(uploaded_file, printer_name, directory_name)
      tracking_a4_print_count(order_ids) if print_job
      print_job
    end

    def print_general_report(uploaded_file, printer_name, directory_name)
      a4_printing(uploaded_file, printer_name, directory_name)
    end

    def a4_printing(uploaded_file, printer_name, directory_name)
      begin
        Dir.mkdir("tmp/#{directory_name}") unless File.exist?("tmp/#{directory_name}")
      rescue Errno::EEXIST
      end
      file_path = Rails.root.join('tmp', directory_name, "#{SecureRandom.hex(10 / 2)}.pdf")
      File.open(file_path, 'wb') do |file|
        file << uploaded_file
      end
      print_job = system("nohup lp -d #{printer_name} #{file_path} > /dev/null 2>&1")
      system("nohup rm #{file_path}") if print_job
      print_job
    end

    def tracking_a4_print_count(order_ids)
      return unless order_ids.is_a?(Array)

      order_ids.each do |order_id|
        ClientOrderPrintTrail.create!(order_id:)
      end
    end

    def oerr_printout(s, person, order)
      s += "\n##########BEGIN FORM##########\n\n"
      s += "\nN\nq616\nQ090,0\nZT\n"
      s += "A140,100,0,4,1,1,N,\"#{GlobalService.current_location.name}\"\n"
      s += "A50,150,0,4,1,1,N,\"Laboratory Test Order Form V2.0.0\"\n"
      s += "A30,250,0,1,1,1,N,\"--------------------------------------------------------\"\n"
      s += "A30,300,0,1,2,2,N,\"PATIENT DETAILS\"\n"
      s += "A30,350,0,4,1,1,N,\"Patient : #{person.fullname} (#{person.sex})\"\n"
      s += "A30,400,0,4,1,1,N,\"Patient ID : #{order.encounter.client.uuid}\"\n"
      s += "A30,450,0,4,1,1,N,\"Patient DOB: #{person.date_of_birth.strftime('%d-%b-%Y')}\"\n"
      s += "A30,500,0,1,1,1,N,\"--------------------------------------------------------\"\n"
      s += "A30,550,0,1,2,2,N,\"ORDER DETAILS\"\n"
      s += "A30,600,0,4,1,1,N,\"Ordered By : #{order.requested_by}\"\n"
      s += "A30,650,0,4,1,1,N,\"Ordered From : #{order.encounter.facility_section.name}\"\n"
      s += "A30,700,0,4,1,1,N,\"Collected at : #{order.sample_collected_time.strftime('%d %b, %Y %H:%M')}\"\n"
      s += "A30,750,0,1,1,1,N,\"--------------------------------------------------------\"\n"
      s += "A30,800,0,1,2,2,N,\"SPECIMEN DETAILS\"\n"
      s += "A30,850,0,4,1,1,N,\"Specimen Type : #{GlobalService.display_name(order.tests.first.specimen.name,
                                                                             order.tests.first.specimen.preferred_name)}\"\n"
      s += "A30,900,0,4,1,1,N,\"Priority : #{order.priority.name}\"\n"
      s += "A30,950,0,1,1,1,N,\"--------------------------------------------------------\"\n"
      s += "A30,1000,0,1,2,2,N,\"CLINICAL HISTORY\"\n"
      s += "A30,1050,0,4,1,1,N,\"#{order.encounter.client_history}\"\n"
      s += "A30,1100,0,1,1,1,N,\"--------------------------------------------------------\"\n"
      s += "A30,1150,0,1,2,2,N,\"Tests\"\n"
      line = 1200
      order.tests.each do |test|
        s += "A80,#{line},0,4,1,1,N,\"-#{GlobalService.display_name(test.test_type.name,
                                                                    test.test_type.preferred_name)}\"\n"
        line += 50
      end
      s += "B100,#{line + 50},0,1A,2,2,120,N,\"#{order.accession_number.scan(/\d+/).first.to_i}\"\n"
      s += "P1\n\n"
      s
    end
  end
end
