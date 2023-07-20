# frozen_string_literal: true

Rails.logger = Logger.new($stdout)
years = Reports::Moh::ReportUtils.report_years
years[-3..-1].reverse.each do |year|
  Rails.logger.info("=====Regenerating Moh Report for #{year}====")
  Reports::MohService.generate_serology_report(year)
  Reports::MohService.generate_microbiology_report(year)
  Reports::MohService.generate_parasitology_report(year)
  Reports::MohService.generate_biochemistry_report(year)
  Reports::MohService.generate_blood_bank_report(year)
  Reports::MohService.generate_haematology_report(year)
end
