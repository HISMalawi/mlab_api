# frozen_string_literal: true

module MachineService
  # Reading Results from Machine
  class ReadingService
    attr_accessor :order

    def initialize(accession_number:)
      @order = Order.find_by!(accession_number:) # OpenStruct.new({ accession_number: })
    end

    def read
      read_json
    end

    private

    # need to read json file from the local disk and parse it
    def read_json
      file = File.read("./tmp/machine_results/#{order.accession_number}.json")
      JSON.parse(file)
    rescue JSON::ParserError => e
      Rails.logger.error(e)
      []
    # rescue from file does not exist
    rescue Errno::ENOENT => e
      Rails.logger.error(e)
      []
    end
  end
end
