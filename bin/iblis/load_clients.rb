last_patient_id = Iblis.find_by_sql("SELECT * FROM patients order by id DESC LIMIT 1")[0].id

def run(start_from, step, last_patient_id)
  clients = IblisService::LoadClientService.get_iblis_clients(start_from, step)
  IblisService::LoadClientService.load_client(clients)
  start_from = start_from + step + 1
  if start_from < last_patient_id
    run(start_from, step, last_patient_id)
  end
end

run(1, 10, last_patient_id)