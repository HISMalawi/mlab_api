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
  end

end
