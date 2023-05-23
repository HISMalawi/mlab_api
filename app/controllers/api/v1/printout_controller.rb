class Api::V1::PrintoutController < ApplicationController
    def print_accession_number
        order = Order.find_by_accession_number(params[:accession_number])
        person = order.encounter.client.person
        label = PrintoutService.print_accession_number(person, order)
        send_data label, type: "application/label;charset=utf-8",
                       stream: false,
                       filename: "#{person.id}-#{SecureRandom.hex(12)}.lbl",
                       disposition: "inline",
                       refresh: "1; url=#{params[:redirect_to]}"
    end

    def print_tracking_number
      order = Order.find_by_tracking_number(params[:tracking_number])
      person = order.encounter.client.person
      label = PrintoutService.print_tracking_number(person, order)
      send_data label, type: "application/label;charset=utf-8",
                      stream: false,
                      filename: "#{person.id}-#{SecureRandom.hex(12)}.lbl",
                      disposition: "inline",
                      refresh: "1; url=#{params[:redirect_to]}"
    end

    def print_zebra_report
      order = Order.find_by_accession_number(params[:accession_number])
      person = order.encounter.client.person
      label  = PrintoutService.print_zebra_report(person, order)
      send_data label, type: "application/label;charset=utf-8",
                      stream: false,
                      filename: "#{person.id}-#{SecureRandom.hex(12)}.lbl",
                      disposition: "inline",
                      refresh: "1; url=#{params[:redirect_to]}"
    end

    def print_patient_report
      uploaded_file = params.require(:pdf)
      printer_name = params.require(:printer_name)
      printed = PrintoutService.print_a4_patient_report(uploaded_file, printer_name)
      render json: { printed: printed }
    end

    def available_a4_printer
      render json: Printer.all
    end
end