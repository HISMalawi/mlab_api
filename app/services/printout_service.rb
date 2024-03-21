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
        if test_.short_name.blank?
          test_.test_type.name
        else
          test_.short_name
        end
      end
      data = is_accession_number ? order.accession_number.scan(/\d+/).first.to_i : order.tracking_number
      f_number = is_accession_number ? order.accession_number : order.tracking_number
      label = ZebraPrinter::Label.new(801, 329, 'T', nil, true)
      # left_align_from = 40
      label.draw_text(person.fullname.to_s, 20, 3, 0, 2, 1, 1)
      # label.draw_text("#{person.date_of_birth&.strftime('%d/%b/%Y')} #{person.sex}", 6 + left_align_from, 29, 0, 1, 1, 2)
      label.draw_barcode(51, 22, 0, '1A', 2, 2, 50, false, data)
      label.draw_text("#{f_number} * #{data}", 51, 81, 0, 2, 1, 1)
      label.draw_text(
        "Col: #{order.created_date.strftime('%d/%b/%Y %H:%M')} #{User.find(order.creator).username}",
        20, 99, 0, 2, 1, 1
      )
      label.draw_text(tests.uniq.join(','), 20, 119, 0, 2, 1, 1)
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
      test_results = []
      if is_cross_match
        pack_abo_group = TestResult.where(
          test_id: Test.where(order_id: order.id),
          test_indicator_id: TestIndicator.where(name: 'Grouping').pluck('id')
        ).first&.value
        # test_results = TestResult.joins(:test_indicator).where(
        #   test_id: Test.where(order_id: order.id)
        # ).where("test_indicators.name <> 'Grouping'").select('test_results.id, test_indicators.name, test_results.value,
        #   test_results.result_date')
        test_results = TestResult.joins(:test_indicator).where(test_id: test_ids)
                                 .select('test_results.id, test_indicators.name, test_results.value,
          test_results.result_date')
      end
      z_label = ZebraPrinter::Label.new
      z_label.line_spacing = 1
      left_align_from = 25
      z_label.draw_text("Accession No: #{accession_number}", 25 + left_align_from, 19, 0, 1, 1, 2)
      unless pack_abo_group.blank?
        z_label.draw_text("ABO Group: #{pack_abo_group}", 320 + left_align_from, 19, 0, 1, 1, 2)
      end
      z_label.draw_text("Date: #{date}", 600 + left_align_from, 19, 0, 1, 1, 2)
      line_y_position = 110
      vertical_pos_reduct_by = 24
      z_label.draw_text("Patient: #{patient}", 25 + left_align_from, 56, 0, 1, 1, 2)
      z_label.draw_text("Ward: #{ward}", 310 + left_align_from, 56, 0, 1, 1, 2)
      z_label.draw_text("By: #{by}", 520 + left_align_from, 56, 0, 1, 1, 2)
      results_length = 1
      multiplier = 0
      test_results.each do |test_result|
        next if test_result.value.blank?

        results_length += 1
        z_label.draw_text(test_result.name.to_s, 53, 116 + (multiplier * 30) - vertical_pos_reduct_by, 0, 1, 1, 2)
        z_label.draw_text(test_result.value.to_s, 455, 116 + (multiplier * 30) - vertical_pos_reduct_by, 0, 1, 1, 2)
        multiplier += 1
      end
      results_length.times do
        z_label.draw_line(25, line_y_position - vertical_pos_reduct_by, 760, 2)
        line_y_position += 30
      end
      z_label.draw_line(785, 110 - vertical_pos_reduct_by, 1, 26 * results_length)
      z_label.draw_line(430, 110 - vertical_pos_reduct_by, 1, 26 * results_length)
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
      file_path = Rails.root.join('tmp', directory_name, uploaded_file.original_filename)
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end
      # system("nohup lp -d #{printer_name} #{file_path} > /dev/null 2>&1")
      print_job = system("nohup lp -d '#{printer_name}' '#{file_path}' > log/printing.log 2>&1")
      system("nohup rm #{file_path}") if print_job
      print_job
    end

    def tracking_a4_print_count(order_ids)
      return unless order_ids.is_a?(Array)

      order_ids.each do |order_id|
        ClientOrderPrintTrail.create!(order_id:)
      end
    end
  end
end
