module Barcode
  module GeneratorService
    class << self
      def generate_specimen_label(accession_number)
        
        # specimen = Specimen.find_by(accession_number: accession_number)
        order = Order.find_by_accession_number(accession_number)
        encounter = Encounter.find_by(id: order.encounter_id)
        order = OrderService.show_order(order, encounter)

        tests = order[:tests]
        npid = order[:npid].nil? ? "-" : order[:npid]
        date = order[:date_created].strftime("%d-%b-%Y %H:%M")
  
        test_names = []
        panels = []
        tests.each do |t|
          next if !t[:panel_id].blank?  and panels.include?(t[:panel_id])
          if t[:panel_id].blank?
            test_names << t[:test_type_short_name] || t[:test_type]
          else
            test_names << TestPanel.find(t[:panel_id]).short_name || TestPanel.find(t[:panel_id]).name
          end
  
        end
  
        tname = test_names.uniq.join(', ')
        first_name = order[:first_name] rescue ""
        last_name = order[:last_name] rescue ""
        middle_initial = order[:middle_name] rescue ""
        dob = order[:date_of_birth].strftime("%d-%b-%Y")
        age = Date.today - order[:date_of_birth]
        gender = order[:sex]
        col_datetime = date
        col_by = order[:registered_by]
        formatted_acc_num = format_ac(order[:accession_number])
        stat_el = order[:priority].downcase.to_s == "stat" ? "STAT" : nil
        numerical_acc_num = numerical_ac(order[:accession_number])
        auto = Barcode::Auto12epl.new
        auto.generate_epl(last_name.to_s, first_name.to_s, middle_initial.to_s, npid.to_s, dob, age.to_s,
                        gender.to_s, col_datetime, col_by.to_s, tname.to_s,
                        stat_el, formatted_acc_num.to_s, numerical_acc_num
                      )
      end
    
      def format_ac(num)
        num = num.insert(3, '-')
        num = num.insert(-9, '-')
        num
      end
    
      def numerical_ac(num)
        settings = GlobalService.current_location
        code = settings['code']
        num = num.sub(/^#{code}/, '')
        num
      end

    end
  end
end