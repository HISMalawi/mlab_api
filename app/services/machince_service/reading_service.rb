# frozen_string_literal: true

module MachineService
  # Reading Results from Machine
  class ReadingService
    attr_accessor :order

    def initialize(accession_number:)
      @order = Order.find_by(accession_number:)
    end

    def read
      data = read_json
      process_indicators(data_hash: data)
      data
    end

    def read_json_file
      read_json
    end

    private

    # need to read json file from the local disk and parse it
    # {"KCH0081502760":{"169":"337.01","147":"10.44","148":"26.1","149":"114 +","150":"40.2","151":"100.2","152":"7","153":"NaN","160":"NaN","161":"NaN","159":"NaN","162":"NaN","163":"NaN","165":"NaN","166":"NaN","164":"0","167":"1","168":"NaN","155":"NaN","154":"NaN","156":"NaN","157":"0.1","176":"NaN","317":"NaN","318":"NaN","319":"NaN","320":"NaN","321":"0","322":"0","158":"NaN","316":"0","315":"0","324":"0","325":"0","323":"0"},"machine_name":"sysmex-xn1000-KCH-HM-15"}
    def read_json
      file = File.read("./tmp/machine_results/#{order.accession_number}.json")
      JSON.parse(file)
    end

    def process_indicators(data_hash:)
      indicators = data_hash[order.accession_number.to_s]
      indicators.each do |key, value|
        test = TestIndicator.find_by(id: key)
        next if test.blank?

        # rename the key to the test name and assign the value to the test result
        indicators[test.name] = value
        indicators.delete(key)
      end
    end
  end
end
