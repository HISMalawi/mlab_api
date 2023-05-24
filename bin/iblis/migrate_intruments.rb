
def migrate_instruments
    instruments = get_instruments
    count = instruments.count
    
        instrument_batch = []
        instrument_mapping_batch = []
        instruments.each_with_index do | instrument, i |
            print "processing #{i} / #{count} \r"
            instrument_batch <<  map_to_instruments(instrument.symbolize_keys)
            instrument_mapping_batch << map_instruments_to_tests(instrument.symbolize_keys) unless instrument['tests'].blank?
        end
        puts "Inserting Instrument records"
        Instrument.insert_all(instrument_batch)
        puts "Clean Instrument Test Type Mapping Table"
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE instrument_test_type_mappings")
        puts "Inserting Instrument test type mapping records"
        InstrumentTestTypeMapping.upsert_all(instrument_mapping_batch
            .flatten)
end

def map_instruments_to_tests(instrument)
    TestType.where(name: instrument[:tests]
        .split(','))
        .pluck(:id)
        .map { | id | { instrument_id: instrument[:id], test_type_id: id }}
end

def map_to_instruments(data)
    {
     id: data[:id],
     name: data[:name],
     description: data[:description],
     ip_address: data[:ip],
     hostname: data[:hostname],
     created_date: data[:created_at],
     updated_date: data[:updated_at]
    }
end

def get_instruments
    IblisBase::connection.select_all('SELECT
        i.id,
        i.name,
        i.description,
        i.ip,
        i.hostname,
        i.created_at,
        i.updated_at,
        group_concat(tt.name) tests
    FROM
        instruments i
    LEFT JOIN instrument_testtypes it 
    ON
        i.id = it.instrument_id
    LEFT JOIN test_types tt 
    ON
        it.test_type_id = tt.id
    GROUP BY i.id,
        i.name,
        i.description,
        i.ip,
        i.hostname,
        i.created_at,
        i.updated_at;
    ')
end

migrate_instruments