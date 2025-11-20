require 'rest-client'
require 'json'

MEASURES = {
  "RBC"=>"147",
  "HGB"=>"148",
  "HCT"=>"149",
  "MCV"=>"150",
  "MCH"=>"151",
  "MCHC"=>"152",
  "PLT"=>"153",
  "RDW-SD"=>"154",
  "RDW-CV"=>"155",
  "PDW"=>"156",
  "MPV"=>"157",
  "PCT"=>"158",
  "NEUT%"=>"159",
  "LYMPH%"=>"160",
  "MONO%"=>"161",
  "EO%"=>"162",
  "BASO%"=>"163",
  "NEUT#"=>"164",
  "LYMPH#"=>"165",
  "MONO#"=>"166",
  "EO#"=>"167",
  "BASO#"=>"168",
  "WBC"=>"169",
  "Mid#"=>"170",
  "GRAN#"=>"171",
  "MID%"=>"172",
  "GRAN%"=>"173",
  "EOS%"=>"174",
  "P-LCC"=>"175",
  "P-LCR"=>"176",
  "MXD%"=>"285",
  "MXD#"=>"286",
  "NRBC#"=>"431",
  "NRBC%"=>"430",
  "RET%"=>"428",
  "RET#"=>"429",
  "IRF"=>"319",
  "LFR"=>"320",
  "MFR"=>"321",
  "HFR"=>"322",
  "RET-HE"=>"323",
  "IG#"=>"324",
  "IG%"=>"325"
}

SPECIMEN_ID = "2500983860"
BASE_URL = "http://127.0.0.1:8005/api/v1/interfacer"

MEASURES.each do |name, measure_id|
  result_value = rand.round(2)  # random number like 0.14, 0.82, 0.05

  url = "#{BASE_URL}?specimen_id=#{SPECIMEN_ID}&measure_id=#{measure_id}&result=#{result_value}&dec=0"

  begin
    response = RestClient::Request.execute(
      method: :get,
      url: url,
      user: "adm",
      password: "1111111",
      timeout: 10
    )

    puts "Sent #{name} (#{measure_id}) => #{result_value} | Response: #{response.code}"
  rescue RestClient::ExceptionWithResponse => e
    puts "Error sending #{name} (#{measure_id}): #{e.response}"
  rescue => e
    puts "General error for #{name}: #{e.message}"
  end
end
