require "csv"

namespace :baan do
  namespace :import do
    
    desc "Load Baan-Users from CSV into Database"
    task :users => :environment do
      
      import_yaml = YAML.load_file("import/import.yml")
      csv_folder = File.join(Rails.root, "import/csv/users/")
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Benutzer.csv')]
      
      current_checksum = import_yaml["csv"]["users"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of USERS... ABORTING TASK!"
      else
        puts "Current USERS VERSION --> #{import_yaml["csv"]["users"]["import_count"]}"

        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          email = "#{row[3].downcase.delete(' ')}.#{row[4].downcase.delete(' ')}@fraefel.ag"
          surname = row[4].downcase.delete(' ')
          forename = row[3].downcase.delete(' ')
          User.find_or_create_by_username(:username => row[6], :email => email, :password => "fraefelExport", :password_confirmation => "fraefelExport", :forename => forename, :surname => surname)
        end
        
        puts "Recalculate IMPORT_COUNTER..."
        import_yaml["csv"]["users"]["import_count"] = import_yaml["csv"]["users"]["import_count"] + 1 if import_yaml["csv"]["users"]["checksum"] != Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Recalculate CHECKSUM..."
        import_yaml["csv"]["users"]["checksum"] = Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Update CONFIG_FILE..."
        File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
        
        puts "Now using VERSION --> #{import_yaml["csv"]["users"]["import_count"]}"
      end
    end
    
    desc "Load Baan-HandelsPartner from CSV into Database"
    task :customers => :environment do
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      csv_folder = File.join(Rails.root, "import/csv/customers/")
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Handelspartner.csv')]
      
      current_checksum = import_yaml["csv"]["customers"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of HANDELSPARTNER... ABORTING TASK!"
      else
        puts "Current HANDELSPARTNER VERSION --> #{import_yaml["csv"]["customers"]["import_count"]}"

        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          company = row[1].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          baan_id = row[3].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          
          if Customer.find_by_baan_id(baan_id)
            customer = Customer.find_by_baan_id(baan_id)
          
            csv_array = [company, baan_id]
            customer_array = [customer.company, customer.baan_id]
          
            if csv_array != customer_array
              customer.update_attributes(:company => company)
            end
          
          else
            Customer.find_or_create_by_company(:company => company, :baan_id => baan_id)
          end
        end
        
        puts "Recalculate IMPORT_COUNTER..."
        import_yaml["csv"]["customers"]["import_count"] = import_yaml["csv"]["customers"]["import_count"] + 1 if import_yaml["csv"]["customers"]["checksum"] != Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Recalculate CHECKSUM..."
        import_yaml["csv"]["customers"]["checksum"] = Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Update CONFIG_FILE..."
        File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
        
        puts "Now using VERSION --> #{import_yaml["csv"]["customers"]["import_count"]}"
      end
    end
    
    
    desc "Load Baan-HandelsPartnerAdressen from CSV into Database"
    task :shipping_addresses => :environment do
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      csv_folder = File.join(Rails.root, "import/csv/customers/")
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Lieferadresse.csv')]
      
      current_checksum = import_yaml["csv"]["shipping_addresses"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of HANDELSPARTNER ADRESSEN... ABORTING TASK!"
      else
        puts "Current HANDELSPARTNER ADRESSEN VERSION --> #{import_yaml["csv"]["shipping_addresses"]["import_count"]}"

        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          street = row[2].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip + " " + row[3].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          zip = row[5]
          city = row[6].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          country = row[4].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          fax = row[8].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          phone_number = row[7].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          baan_id = row[0].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          if Customer.find_by_baan_id(baan_id) && Customer.find_by_baan_id(baan_id).shipping_addresses.first.present?
            customer = Customer.find_by_baan_id(baan_id)
            address = customer.shipping_addresses.first
            
            csv_array = [street, zip, city, country, fax, phone_number]
            customer_array = [address.street, address.zip, address.city, address.country, address.fax, address.phone_number]
          
            if csv_array != customer_array
              address.update_attributes(:street => street, :zip => zip, :city => city, :country => country, :fax => fax, :phone_number => phone_number)
            end
          
          else
            if Customer.find_by_baan_id(baan_id).present?
              Customer.find_by_baan_id(baan_id).shipping_addresses.build(:street => street, :zip => zip, :city => city, :country => country, :fax => fax, :phone_number => phone_number).save
            else
              # Should write in LOG
            end
          end
        end
        
        puts "Recalculate IMPORT_COUNTER..."
        import_yaml["csv"]["shipping_addresses"]["import_count"] = import_yaml["csv"]["shipping_addresses"]["import_count"] + 1 if import_yaml["csv"]["shipping_addresses"]["checksum"] != Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Recalculate CHECKSUM..."
        import_yaml["csv"]["shipping_addresses"]["checksum"] = Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Update CONFIG_FILE..."
        File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
        
        puts "Now using VERSION --> #{import_yaml["csv"]["shipping_addresses"]["import_count"]}"
      end
    end
    
    desc "Load CommodityCodes from CSV into Database"
    task :commodity_codes => :environment do
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      csv_folder = File.join(Rails.root, "import/csv/purchase_orders/")
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Versand.csv')]
      
      current_checksum = import_yaml["csv"]["commodity_codes"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of COMMODITY CODES... ABORTING TASK!"
      else
        puts "Current COMMODITY CODES VERSION --> #{import_yaml["csv"]["commodity_codes"]["import_count"]}"

        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          code = row[0].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          content = row[1].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          
          if CommodityCode.find_by_code(code)
            commodity_code = CommodityCode.find_by_code(code)
            
            csv_array = [code, content]
            code_array = [commodity_code.code, commodity_code.content]
          
            if csv_array != code_array
              commodity_code.update_attributes(:code => code, :content => content)
            end
          
          else
            CommodityCode.find_or_create_by_code(:code => code, :content => content)
          end
        end
        
        puts "Recalculate IMPORT_COUNTER..."
        import_yaml["csv"]["commodity_codes"]["import_count"] = import_yaml["csv"]["commodity_codes"]["import_count"] + 1 if import_yaml["csv"]["commodity_codes"]["checksum"] != Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Recalculate CHECKSUM..."
        import_yaml["csv"]["commodity_codes"]["checksum"] = Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Update CONFIG_FILE..."
        File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
        
        puts "Now using VERSION --> #{import_yaml["csv"]["commodity_codes"]["import_count"]}"
      end
    end
    
    desc "Load Purchase Orders from CSV into Database"
    task :purchase_orders => :environment do
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      csv_folder = File.join(Rails.root, "import/csv/purchase_orders/")
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Versand.csv')]
      
      current_checksum = import_yaml["csv"]["purchase_orders"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of PURCHASE ORDERS... ABORTING TASK!"
      else
        puts "Current PURCHASE ORDERS VERSION --> #{import_yaml["csv"]["purchase_orders"]["import_count"]}"
        
        if PurchaseOrder.all.present?
          puts "RE-IMPORT Purchase Orders..."
        else
          puts "Currently no Purchase Orders in Database... Try to import from CSV"
        end
        
        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          customer = Customer.find_by_baan_id(row[6].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip)
          baan_id = row[2].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          csv_customer = row[6].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          delivery_route = row[21].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
        
          purchase_order = PurchaseOrder.find_or_initialize_by_baan_id(:baan_id => baan_id, :customer => customer, :status => "open", :delivery_route => delivery_route)
          if purchase_order.present? && purchase_order.new_record?
            purchase_order.save
            puts "New Purchase Order has been created: #{purchase_order.attributes}"
          else
            if (purchase_order.baan_id == baan_id && purchase_order.status == "open" && purchase_order.customer.baan_id != csv_customer)
              purchase_order.update_attributes(:customer => customer)
              puts "Purchase Order #{purchase_order.id} was updated with a different Customer... You should check it manualy!"
            end
          end
        end
        
        puts "Recalculate IMPORT_COUNTER..."
        import_yaml["csv"]["purchase_orders"]["import_count"] = import_yaml["csv"]["purchase_orders"]["import_count"] + 1 if import_yaml["csv"]["purchase_orders"]["checksum"] != Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Recalculate CHECKSUM..."
        import_yaml["csv"]["purchase_orders"]["checksum"] = Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Update CONFIG_FILE..."
        File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
        
        puts "Now using VERSION --> #{import_yaml["csv"]["purchase_orders"]["import_count"]}"
      end
    end
    
    desc "Load Purchase Positions from CSV into Database"
    task :purchase_positions => :environment do
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      csv_folder = File.join(Rails.root, "import/csv/purchase_orders/")
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Versand.csv')]
      
      current_checksum = import_yaml["csv"]["purchase_positions"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of PURCHASE POSITIONS... ABORTING TASK!"
      else
        puts "Current PURCHASE POSITIONS VERSION --> #{import_yaml["csv"]["purchase_positions"]["import_count"]}"
        
        if PurchasePosition.all.present?
          puts "RE-IMPORT Purchase Positions..."
        else
          puts "Currently no Purchase Positions in Database... Try to import from CSV"
        end

        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          baan_id = row[2].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          commodity_code = CommodityCode.find_by_code(row[0].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip)
          purchase_order = PurchaseOrder.find_by_baan_id(baan_id)
          weight_single = row[15].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip.to_f
          weight_total = row[16].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip.to_f
          quantity = row[18].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip.to_f
          amount = row[17].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip.to_f
          position = row[4].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip.to_i
          delivery_date = row[13].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          article = row[27].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          article_number = row[26].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          product_line = row[29].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          storage_location = row[23].to_s.force_encoding("UTF-8").chomp.lstrip.rstrip
          
          
          if purchase_order.purchase_positions.where(:position => position).present?
            purchase_position = purchase_order.purchase_positions.where(:position => position).first
            csv_array = [weight_single.to_s, weight_total.to_s, quantity.to_s, amount.to_s, position]
            purchase_position_array = [purchase_position.weight_single.to_s, purchase_position.weight_total.to_s, purchase_position.quantity.to_s, purchase_position.amount.to_s, purchase_position.position]
            if (csv_array != purchase_position_array && purchase_position.status == "open")
              purchase_position.update_attributes(:commodity_code => commodity_code, :weight_single => weight_single, :weight_total => weight_total, :quantity => quantity, :amount => amount, :position => position, :status => "open", :article => article, :product_line => product_line, :storage_location => storage_location, :article_number => article_number)
              puts "Found differences. Update Position..."
            end
          else
            purchase_position = purchase_order.purchase_positions.build(:commodity_code => commodity_code, :weight_single => weight_single, :weight_total => weight_total, :quantity => quantity, :amount => amount, :position => position, :status => "open", :delivery_date => delivery_date, :article => article, :product_line => product_line, :storage_location => storage_location, :article_number => article_number)
            purchase_position.save
            puts "New Purchase Position has been created: #{purchase_position.attributes}"
          end
        end
        
        puts "Recalculate IMPORT_COUNTER..."
        import_yaml["csv"]["purchase_positions"]["import_count"] = import_yaml["csv"]["purchase_positions"]["import_count"] + 1 if import_yaml["csv"]["purchase_positions"]["checksum"] != Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Recalculate CHECKSUM..."
        import_yaml["csv"]["purchase_positions"]["checksum"] = Digest::SHA1.hexdigest(File.read(csv_file[0]))
        
        puts "Update CONFIG_FILE..."
        File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
        
        puts "Now using VERSION --> #{import_yaml["csv"]["purchase_positions"]["import_count"]}"
      end
    end
    
    desc "Create user tzhbami7 and assign Admin Role"
    task :default_data => :environment do
      User.find_or_create_by_username(:username => "tzhbami7", :forename => "Michael", :surname => "Balsiger", :email => "michael.balsiger@swisscom.com", :password => "masT!44!", :password_confirmation => "masT!44!")
      Role.find_or_create_by_name(:name => "admin", :active => true)
      User.where(:username => "tzhbami7").first.roles.include?(Role.where(:name => "admin").first) ? nil : (User.where(:username => "tzhbami7").first.roles << Role.where(:name => "admin").first)
    end
    
    desc "Reset CONFIG_FILE"
    task :reset => :environment do
      
      import_yaml = YAML.load_file("import/import.yml")
      csv_folder = File.join(Rails.root, "import/csv/users/")
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Benutzer.csv')]
      
      puts "Reset IMPORT_COUNTER..."
      import_yaml["csv"]["users"]["import_count"] = 0
      import_yaml["csv"]["customers"]["import_count"] = 0
      import_yaml["csv"]["shipping_addresses"]["import_count"] = 0
      import_yaml["csv"]["commodity_codes"]["import_count"] = 0
      import_yaml["csv"]["purchase_orders"]["import_count"] = 0
      import_yaml["csv"]["purchase_positions"]["import_count"] = 0
      
      puts "Reset CHECKSUM..."
      import_yaml["csv"]["users"]["checksum"] = ""
      import_yaml["csv"]["customers"]["checksum"] = ""
      import_yaml["csv"]["shipping_addresses"]["checksum"] = ""
      import_yaml["csv"]["commodity_codes"]["checksum"] = ""
      import_yaml["csv"]["purchase_orders"]["checksum"] = ""
      import_yaml["csv"]["purchase_positions"]["checksum"] = ""
      
      puts "Update CONFIG_FILE..."
      File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
    end
    
  end
end
