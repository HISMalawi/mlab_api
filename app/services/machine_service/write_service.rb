# frozen_string_literal: true

module MachineService
  # Writing Results to Machine
  class WriteService
    attr_accessor :order, :machine_name, :measure_id, :result

    def initialize(specimen_id:, machine_name:, measure_id:, result:)
      @order = Order.find_by!(accession_number: specimen_id) # OpenStruct.new({ accession_number: specimen_id })
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
      process_hash(hash: to_write)
      File.write("./tmp/machine_results/#{order.accession_number}.json", JSON.dump(to_write))
    end

    def process_hash(hash:)
      if check_indicator_exists?(hash:)
        update_indicator(hash:)
      else
        write_measure(hash:)
      end
    end

    def process_file
      create_directory unless check_directory?
      create_file unless file_exists?
    end

    def write_measure(hash:)
      hash << {
        indicator_id: @measure_id,
        value: @result,
        machine_name:,
        indicator_name: TestIndicator.find_by(id: @measure_id)&.name
      }
    end

    def check_indicator_exists?(hash:)
      hash.each do |h|
        return true if h['indicator_id'] == measure_id && h['machine_name'] == machine_name
      end
      false
    end

    def update_indicator(hash:)
      hash.each do |h|
        next unless h['indicator_id'] == measure_id && h['machine_name'] == machine_name

        h['value'] = result
        break
      end
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
