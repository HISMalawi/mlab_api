class Api::V1::PrintoutController < ApplicationController
  def print_accession_number
    order = Order.find_by_accession_number(params[:accession_number])
    person = order.encounter.client.person
    label = PrintoutService.print_accession_number(person, order)
    label = PrintoutService.oerr_printout(label, person, order) if params[:oerr].present?
    send_data label, type: 'application/label;charset=utf-8',
                     stream: false,
                     filename: "#{person.id}-#{SecureRandom.hex(12)}.lbl",
                     disposition: 'inline',
                     refresh: "1; url=#{params[:redirect_to]}"
  end

  def print_tracking_number
    order = Order.find_by_tracking_number(params[:tracking_number])
    person = order.encounter.client.person
    label = PrintoutService.print_tracking_number(person, order)
    send_data label, type: 'application/label;charset=utf-8',
                     stream: false,
                     filename: "#{person.id}-#{SecureRandom.hex(12)}.lbl",
                     disposition: 'inline',
                     refresh: "1; url=#{params[:redirect_to]}"
  end

  def print_zebra_report
    is_cross_match = params[:is_cross_match].blank? ? false : true
    order = Order.find(params[:order_id])
    person = order.encounter.client.person
    label  = PrintoutService.print_zebra_report(person, order, params[:tests], is_cross_match)
    send_data label, type: 'application/label;charset=utf-8',
                     stream: false,
                     filename: "#{person.id}-#{SecureRandom.hex(12)}.lbl",
                     disposition: 'inline',
                     refresh: "1; url=#{params[:redirect_to]}"
  end

  def print_patient_report
    # uploaded_file = params.require(:pdf)
    printer_name = params.require(:printer_name)
    order_ids = params.require(:order_ids)
    client_id = params.require(:client_id)
    directory_name = 'patient_reports'
    grover = Grover.new("http://#{request.host}:#{request.port}/api/v1/print_patient_reports?from=&to=&client_id=#{client_id}&order_ids=#{JSON.parse(order_ids)}",
                        display_header_footer: true,
                        footer_template: "<div class='text right' style='align: center; margin-left: 50%'>Page <span class='pageNumber'>
                        </span> of <span class='totalPages'></span></div>",
                        margin: { top: '0in', bottom: '0.5in' }, format: 'A4', print_background: true).to_pdf
    order_ids = order_ids.is_a?(String) ? JSON.parse(order_ids) : order_ids
    printed = PrintoutService.print_patient_report(grover, printer_name, directory_name, order_ids)
    render json: { printed: }
  end

  def print_general_report
    uploaded_file = params.require(:pdf)
    printer_name = params.require(:printer_name)
    directory_name = 'general_reports'
    printed = PrintoutService.print_general_report(uploaded_file, printer_name, directory_name)
    render json: { printed: }
  end
end
