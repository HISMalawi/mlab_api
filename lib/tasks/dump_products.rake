namespace :import do
    desc "import OpenMRS stock management products"
    task :products => :environment do
        require 'roo'
        def dump_products(file_path)
            spreadsheet = Roo::Spreadsheet.open(file_path.to_s)
            header = spreadsheet.row(1)
            (2..spreadsheet.last_row).each do |i|
                row = Hash[[header, spreadsheet.row(i)].transpose]
                create_or_skip_stock_item(row)
              end
        end

        private
        def create_or_skip_stock_item(row)
            ActiveRecord::Base.transaction do
              existing_stock_item = StockItem.find_by(name: row['name'])
              if existing_stock_item
                Rails.logger.info "Stock item '#{existing_stock_item.name}' already exists. Skipping..."
                puts "Stock item '#{existing_stock_item.name}' already exists. Skipping..."
                return
              end

              stock_item = StockItem.create!(
                product_code: row['productCode'],
                name: row['name'],
                stock_category_id: StockCategory.find_or_create_by!(name: row['category']).id,
                description: row['description'],
                measurement_unit: StockUnit.find_or_create_by!(name: row['dispensable'].gsub('dispensingUnit:', '').strip()).id,
                quantity_unit: row['packSize'],
                strength: row['Strength']
              )
      
              Stock.create!(
                stock_item_id: stock_item.id,
                stock_location_id: row['Stock Location ID'] || 1,
                quantity: 0,
                minimum_order_level: row['Minimum Order Level'] || 0
              )
      
              puts "Stock item '#{stock_item.name}' created successfully."
            end
          end

        dump_products(Rails.root.join('lib', 'dumps', 'merged_products.csv'))
        puts "Import completed successfully!"
    end
end