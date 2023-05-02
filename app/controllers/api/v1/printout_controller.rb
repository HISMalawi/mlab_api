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
end