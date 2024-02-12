# frozen_string_literal: true

# MohReport job
class MohReportJob
  include Sidekiq::Job

  def perform
    report_years = Reports::Moh::ReportUtils.report_years.reverse.first(2)
    report_years[].each do |year|
      Report.find_or_create_by(name: 'moh_haematology', year:).update(
        data: Reports::MohService.generate_haematology_report(year)
      )
      Report.find_or_create_by(name: 'moh_blood_bank', year:).update(
        data: Reports::MohService.generate_blood_bank_report(year)
      )
      Report.find_or_create_by(name: 'moh_biochemistry', year:).update(
        data: Reports::MohService.generate_biochemistry_report(year)
      )
      Report.find_or_create_by(name: 'moh_serology', year:).update(
        data: Reports::MohService.generate_serology_report(year)
      )
      Report.find_or_create_by(name: 'moh_microbiology', year:).update(
        data: Reports::MohService.generate_microbiology_report(year)
      )
      Report.find_or_create_by(name: 'moh_parasitology', year:).update(
        data: Reports::MohService.generate_parasitology_report(year)
      )
    end
  end
end
MohReportJob.perform_async
