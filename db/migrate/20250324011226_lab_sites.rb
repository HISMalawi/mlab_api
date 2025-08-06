# frozen_string_literal: true

# Lab Sites
class LabSites < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:lab_test_sites)
    
    create_table :lab_test_sites do |t|
      t.string :name
      t.text :description
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :lab_test_sites, :users, column: :creator, primary_key: :id
    add_foreign_key :lab_test_sites, :users, column: :updated_by, primary_key: :id
    add_foreign_key :lab_test_sites, :users, column: :voided_by, primary_key: :id

    lab_test_sites_data = [
      { name: 'Community Setting',
        description: 'A setting where health services are provided in the community, often with limited diagnostic capabilities.' },
      { name: 'Primary health facilities without laboratories',
        description: 'Basic health facilities that provide primary care but do not have laboratory services for diagnostic testing.' },
      { name: 'Primary health facilities with clinical laboratories (including urban health centres)',
        description: 'Primary care health facilities equipped with clinical laboratories, including urban health centres that provide diagnostic testing services.' },
      { name: 'Secondary level health facilities (including community hospitals)',
        description: 'Health facilities providing specialized care and diagnostic services, including community hospitals offering more advanced medical services.' },
      { name: 'Tertiary level health facilities',
        description: 'Advanced healthcare facilities offering specialized treatment, surgeries, and diagnostic testing, typically located in larger urban areas.' },
      { name: 'National public health reference laboratory',
        description: 'A national laboratory focused on public health surveillance, providing reference testing and supporting national health programs.' }
    ]

    # Inserting the data
    lab_test_sites_data.each do |data|
      execute <<-SQL
        INSERT INTO lab_test_sites (name, description, creator, voided, created_date, updated_date)
        VALUES ('#{data[:name]}', '#{data[:description]}', #{User.first.id}, false, NOW(), NOW())
      SQL
    end
  end

  def down
    drop_table :lab_test_sites
  end
end
