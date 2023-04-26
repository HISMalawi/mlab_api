# frozen_string_literal: true

module MachineService
  # Writing Results to Machine
  class WriteService
    attr_accessor :order, :machine_name, :measure_id, :result

    def initialize(specimen_id:, machine_name:, measure_id:, result:)
      @order = Order.find_by!(accession_number: specimen_id)
      @machine_name = machine_name
      @measure_id = measure_id
      @result = result
    end

    def write
      return unless order.present?

      write_to_disk
    end

    private

    def read_json_file
      ReadingService.new(accession_number: order.accession_number).read
    end

    def write_to_disk
      process_file
      to_write = read_json_file
      init_hash(to_write)
      write_measure(hash: to_write[order.accession_number], measure_id:, result:)
      File.write("./tmp/machine_results/#{order.accession_number}.json", JSON.dump(to_write))
    end

    def init_hash(hash)
      hash[order.accession_number] = {} unless hash[order.accession_number]
    end

    def process_file
      create_directory unless check_directory?
      create_file unless file_exists?
    end

    def write_measure(hash:, measure_id:, result:)
      hash[measure_id.to_s] = {
        value: result,
        machine_name:,
        indicator_name: TestIndicator.find_by(id: measure_id)&.name
      }
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
      puts file
      File.exist?(file)
    end

    def create_file
      # create the file
      file = File.join(Rails.root, 'tmp', 'machine_results', "#{order.accession_number}.json")
      File.new(file, 'w')
    end
  end
end
