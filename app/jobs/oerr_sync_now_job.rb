# frozen_string_literal: true

# OERR SYNC JOB
class OerrSyncNowJob
  include Sidekiq::Job

  def perform(id)
    oerr_sync_trail = OerrSyncTrail.find_by(id:)
    oerr_config = OerrService.oerr_configs
    url = "#{oerr_config[:base_url]}/update_order"
    response = RestClient::Request.execute(
              method: :post,
              url:,
              payload: OerrService.to_oerr_dto(oerr_sync_trail).to_json,
              headers: { content_type: :json, accept: :json },
              user: oerr_config[:username],
              password: oerr_config[:password]
            )
    if response.code == 200
      data = JSON.parse(response.body)
      OerrService.oerr_sync_trail_update(oerr_sync_trail, data['doc_id'])
    else
      Rails.logger.error "Error pushing to oerr #{response.body}"
      raise "Error pushing to oerr #{response.body}"
    end
  end
end
