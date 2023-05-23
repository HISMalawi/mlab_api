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

    def print_zebra_report(person, order)
  
      specimen_name =  Test.joins(:specimen).where(order_id: order.id).pick(:name)
      test_type_name = Test.joins(:test_type).where(order_id: order.id).pick(:name)
      test_result = TestResult.joins(:test).select("COALESCE(test_results.value, 'null') AS value").where("tests.order_id = ?", order.id)
      label = ZebraPrinter::Label.new
      label.x = 250
      label.font_size = 2
      label.draw_text("#{person.fullname} ( #{person.sex},#{person.date_of_birth}) | Pat.No: sasaaas | Date: asas", 53, 19, 0, 1, 1,1)
      label.draw_line(25, 80, 760, 2)
      label.draw_text("Sample Type:", 53, 56, 0, 1, 1, 2)
      label.draw_text(" Sample ID:",325, 56, 0, 1, 1, 2)
      label.draw_text("#{specimen_name}", 190, 56, 0, 1, 1, 2)
      label.draw_text("#{order.accession_number}", 450, 56, 0, 1, 1, 2)
      label.draw_text("Test: #{test_type_name}",450, 56, 0, 1, 1)
      label.draw_line(25, 85, 760, 1)
      label.draw_text("#{test_type_name}", 53, 130, 0, 2, 1, 1)
      label.draw_text("#{} copies", 455, 130, 0, 2, 1, 1)
      label.draw_line(25, 165, 760, 1)
      label.print(1)
    end

    def print_a4_patient_report(uploaded_file, printer_name, order_id)
      directory_name = 'patient_reports'
      begin
        Dir.mkdir("tmp/#{directory_name}") unless File.exist?(directory_name)          
      rescue Errno::EEXIST
        
      end
      file_path = Rails.root.join('tmp', directory_name, uploaded_file.original_filename)
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end
      # system("nohup lp -d #{printer_name} #{file_path} > /dev/null 2>&1")
      print_job = system("nohup lp -d '#{printer_name}' '#{file_path}' > log/printing.log 2>&1")
      if print_job
        system("nohup rm #{file_path}")
        tracking_a4_print_count(order_id)
      end
      print_job
    end

    def tracking_a4_print_count(order_id)
      ClientOrderPrintTrail.create!(order_id: order_id)
    end
  end

end
