module PrintoutService
  class << self
    def print_accession_number(person, order)
      tests = order.tests.map do |_test|
        _test.short_name if !_test.short_name.blank?
        _test.test_type.name
      end
      label = ZebraPrinter::Label.new
      label.x = 250
      label.font_size = 2
      label.draw_multi_text(person.fullname)
      label.draw_multi_text("#{person.date_of_birth}  #{person.sex}")
      label.draw_multi_text("#{order.accession_number} * #{order.accession_number.scan(/\d+/).first.to_i}")
      label.draw_barcode(250, 180, 0, 1, 5, 15, 120, false, order.accession_number.scan(/\d+/).first.to_i)
      label.draw_multi_text("Col: #{order.created_date.strftime("%d/%b/%Y %H:%M")} #{User.find(order.creator).username}")
      label.draw_multi_text(tests.join(", "))
      label.print(1)
    end
    
    def print_tracking_number(person, order)
      tests = order.tests.map do |_test|
        _test.short_name if !_test.short_name.blank?
        _test.test_type.name
      end
      label = ZebraPrinter::Label.new
      label.x = 250
      label.font_size = 2
      label.draw_multi_text(person.fullname)
      label.draw_multi_text("#{person.date_of_birth}  #{person.sex}")
      label.draw_multi_text("#{order.tracking_number} * #{order.tracking_number.scan(/\d+/).first.to_i}")
      label.draw_barcode(250, 180, 0, 1, 5, 15, 120, false, order.tracking_number)
      label.draw_multi_text("Col: #{order.created_date.strftime("%d/%b/%Y %H:%M")} #{User.find(order.creator).username}")
      label.draw_multi_text(tests.join(", "))
      label.print(1)
    end

    def print_zebra_report(person, order, test_ids)
      accession_number = order.accession_number
      patient = person.fullname
      date = Date.today.strftime
      ward = order.encounter&.facility_section&.name
      by = User.where(id: TestStatus.where(test_id: test_ids, status_id: 4).first&.creator).first&.person&.fullname
      pack_abo_group = TestResult.where(
        test_id: Test.where(order_id: order.id),
        test_indicator_id: TestIndicator.where(name: 'Grouping').pluck('id')
      ).first&.value
      test_results = TestResult.joins(:test_indicator).where(
        test_id: Test.where(order_id: order.id)
      ).where("test_indicators.name <> 'Grouping'").select('test_results.id, test_indicators.name, test_results.value,
        test_results.result_date')
      pack_abo_group = pack_abo_group.blank? ? '' : pack_abo_group
      z_label = ZebraPrinter::Label.new
      z_label.line_spacing = 1
      left_align_from = 25
      z_label.draw_text("Accession No: #{accession_number}", 25 + left_align_from, 19, 0, 1, 1, 2)
      z_label.draw_text("ABO Group: #{pack_abo_group}", 320+ left_align_from, 19, 0, 1, 1, 2)
      z_label.draw_text("Date: #{date}", 600 + left_align_from, 19, 0, 1, 1, 2)
      line_y_position = 110
      vertical_pos_reduct_by = 24
      results_length = test_results.length + 1
      results_length.times do
        z_label.draw_line(25, line_y_position - vertical_pos_reduct_by, 760, 2)
        line_y_position += 30
      end
      z_label.draw_line(785, 110-vertical_pos_reduct_by, 1, 26 * results_length)
      z_label.draw_line(430, 110-vertical_pos_reduct_by, 1, 26 * results_length)
      z_label.draw_text("Patient: #{patient}", 25 + left_align_from, 56, 0, 1, 1, 2)
      z_label.draw_text("Ward: #{ward}", 310 + left_align_from, 56, 0, 1, 1, 2)
      z_label.draw_text("By: #{by}", 520 + left_align_from, 56, 0, 1, 1, 2)
      test_results.each_with_index do |test_result, index|
        z_label.draw_text(test_result.name.to_s, 53, 116 + (index * 30) - vertical_pos_reduct_by, 0, 1, 1, 2)
        z_label.draw_text(test_result.value.to_s, 455, 116 + (index * 30) - vertical_pos_reduct_by, 0, 1, 1, 2)
      end
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
      if order_ids.is_a?(Array)
        order_ids.each do |order_id|
          ClientOrderPrintTrail.create!(order_id:)
        end
      end
    end
  end

end
