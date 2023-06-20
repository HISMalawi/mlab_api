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
      specimen_name =  Test.joins(:specimen).where(order_id: order.id).pick(:name)
      label = ZebraPrinter::Label.new
      label.x = 250
      label.font_size = 2
      label.draw_text("#{person.fullname} ( #{person.sex},#{person.date_of_birth.strftime('%d/%b/%Y')}) | Pat.No: #{person.id} | Date: #{person.created_date.strftime('%d/%b/%Y')}", 53, 19, 0, 1, 1,1)
      label.draw_line(25, 80, 760, 2)
      label.draw_text("Sample Type:", 53, 56, 0, 1, 1, 2)
      label.draw_text(" Sample ID:",325, 56, 0, 1, 1, 2)
      label.draw_text("#{specimen_name}", 190, 56, 0, 1, 1, 2)
      label.draw_text("#{order.accession_number}", 450, 56, 0, 1, 1, 2)

      test_ids.each do |test_id|
        test = Test.find(test_id)
        test_type_name = test.test_type.name
        test_results = TestResult.joins(:test_indicator).where(test_id: test.id).select('test_results.id, test_indicators.name, test_results.value, test_results.result_date')
        label.draw_text("Test: #{test_type_name}",450, 56, 0, 1, 1)
        label.draw_line(25, 85, 760, 1)
        test_results.each do |test_result|
          label.draw_text("#{test_result.name}", 53, 130, 0, 2, 1, 1)
          label.draw_text("#{test_result.value}", 455, 130, 0, 2, 1, 1)
          label.draw_line(25, 165, 760, 1)
        end
      end
      label.print(1)
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
