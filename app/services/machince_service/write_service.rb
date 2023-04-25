# frozen_string_literal: true

module MachineService
  # Writing Results to Machine
  class WriteService
    attr_accessor :order, :machine_name, :measure_id, :result

    def initialize(specimen_id:, machine_name:, measure_id:, result:)
      @order = Order.find_by(accession_number: specimen_id)
      @machine_name = machine_name
      @measure_id = measure_id
      @result = result
    end

    def write
      return unless order.present?

      write_to_machine
    end

    private

    def read_json_file
      ReadingService.new(accession_number: order.accession_number).read_json_file
    end

    def write_to_disk
      create_directory unless check_directory?
      create_file unless file_exists?

      to_write = read_json_file
      to_write[order.accession_number.to_s][measure_id.to_s] = result if measure_id
      to_write['machine_name'] = machine_name if machine_name
      File.write("./tmp/machine_results/#{order.accession_number}.json", JSON.dump(to_write))
    end

    def check_directory?
      # check if the directory exists tmp/machine_results
      dir = File.join(Rails.root, 'tmp', 'machine_results')
      Dir.exist?(dir)
    end

    def create_directory
      # create the directory tmp/machine_results
      dir = File.join(Rails.root, 'tmp', 'machine_results')
      Dir.mkdir(dir)
    end

    def file_exists?
      # check if the file exists
      file = File.join(Rails.root, 'tmp', 'machine_results', "#{order.accession_number}.json")
      File.exist?(file)
    end

    def create_file
      # create the file
      file = File.join(Rails.root, 'tmp', 'machine_results', "#{order.accession_number}.json")
      File.new(file, 'w')
    end
  end
end
