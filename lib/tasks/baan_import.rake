require "csv"

namespace :baan do
  namespace :import do
    
    desc "Load Baan-Users from CSV into Database"
    task :users, [:import_path] => :environment do |t, args|
      
      import_yaml = YAML.load_file("import/import.yml")
      
      csv_folder = args[:import_path] ? ("/Users/sufu/code/rails/fraefel" + "/import/csv/") : "/home/ivo/csv/"
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Benutzer.csv')]
      
      current_checksum = import_yaml["csv"]["users"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of USERS... ABORTING TASK!"
      else
        puts "Current USERS VERSION --> #{import_yaml["csv"]["users"]["import_count"]}"

        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          email = "#{row[3].downcase.delete(' ')}.#{row[4].downcase.delete(' ')}@fraefel.ag"
          surname = Iconv.conv('UTF-8', 'iso-8859-1', row[4]).to_s.downcase.delete(' ')
          forename = Iconv.conv('UTF-8', 'iso-8859-1', row[3]).to_s.downcase.delete(' ')
          username = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.downcase.delete(' ')
          User.find_or_create_by_username(:username => username, :email => email, :password => "fraefelExport", :password_confirmation => "fraefelExport", :forename => forename, :surname => surname)
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
    task :customers, [:import_path] => :environment do |t, args|
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      csv_folder = args[:import_path] ? ("/Users/sufu/code/rails/fraefel" + "/import/csv/") : "/home/ivo/csv/"
      csv_file = csv_folder + 'BaanRead_Versand.csv'
      current_checksum = import_yaml["csv"]["customers"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of HANDELSPARTNER... ABORTING TASK!"
      else
        puts "Current HANDELSPARTNER VERSION --> #{import_yaml["csv"]["customers"]["import_count"]}"

        CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
          company = Iconv.conv('UTF-8', 'iso-8859-1', row[5]).to_s.chomp.lstrip.rstrip
          #baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip
          baan_id = row[6].to_s.chomp.lstrip.rstrip
          
          customer = Customer.find_or_initialize_by_baan_id(:baan_id => baan_id, :company => company)
          
          if customer.present? && customer.new_record?
            if customer.save
              #puts "New Customer has been created: #{customer.attributes}"
            else
              puts "ERROR-- Customer not saved..."
            end
          else
            if (customer.baan_id == baan_id && customer.company != company)
              customer.update_attributes(:company => company)
              puts "Customer #{customer.id} was updated with a different Copmany Name... You should check it manualy!"
            end
          end
          
        end
        
        puts "Recalculate IMPORT_COUNTER..."
        import_yaml["csv"]["customers"]["import_count"] = import_yaml["csv"]["customers"]["import_count"] + 1 if import_yaml["csv"]["customers"]["checksum"] != Digest::SHA1.hexdigest(File.read(csv_file))
        
        puts "Recalculate CHECKSUM..."
        import_yaml["csv"]["customers"]["checksum"] = Digest::SHA1.hexdigest(File.read(csv_file))
        
        puts "Update CONFIG_FILE..."
        File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
        
        puts "Now using VERSION --> #{import_yaml["csv"]["customers"]["import_count"]}"
      end
    end
    
    
    desc "Load Baan-HandelsPartnerAdressen from CSV into Database"
    task :shipping_addresses, [:import_path] => :environment do |t, args|
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      
      csv_folder = args[:import_path] ? ("/Users/sufu/code/rails/fraefel" + "/import/csv/") : "/home/ivo/csv/"
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Versand.csv')]
      
      current_checksum = import_yaml["csv"]["shipping_addresses"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of HANDELSPARTNER ADRESSEN... ABORTING TASK!"
      else
        puts "Current HANDELSPARTNER ADRESSEN VERSION --> #{import_yaml["csv"]["shipping_addresses"]["import_count"]}"

        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          street = Iconv.conv('UTF-8', 'iso-8859-1', row[7]).to_s.chomp.lstrip.rstrip + " " + Iconv.conv('UTF-8', 'iso-8859-1', row[8]).to_s.chomp.lstrip.rstrip
          zip = row[10]
          city = Iconv.conv('UTF-8', 'iso-8859-1', row[11]).to_s.chomp.lstrip.rstrip
          country = Iconv.conv('UTF-8', 'iso-8859-1', row[9]).to_s.chomp.lstrip.rstrip
          baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip
          if Customer.find_by_baan_id(baan_id) && Customer.find_by_baan_id(baan_id).shipping_addresses.first.present?
            customer = Customer.find_by_baan_id(baan_id)
            address = customer.shipping_addresses.first
            
            csv_array = [street, zip, city, country]
            customer_array = [address.street, address.zip, address.city, address.country]
          
            if csv_array != customer_array
              address.update_attributes(:street => street, :zip => zip, :city => city, :country => country)
            end
          
          else
            if Customer.find_by_baan_id(baan_id).present?
              Customer.find_by_baan_id(baan_id).shipping_addresses.build(:street => street, :zip => zip, :city => city, :country => country).save
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
    task :commodity_codes, [:import_path] => :environment do |t, args|
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      
      csv_folder = args[:import_path] ? ("/Users/sufu/code/rails/fraefel" + "/import/csv/") : "/home/ivo/csv/"
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Versand.csv')]
      
      current_checksum = import_yaml["csv"]["commodity_codes"]["checksum"]
      csv_checksum = Digest::SHA1.hexdigest(File.read(csv_file[0]))
      
      if current_checksum.to_s == csv_checksum.to_s
        puts "Already newest version of COMMODITY CODES... ABORTING TASK!"
      else
        puts "Current COMMODITY CODES VERSION --> #{import_yaml["csv"]["commodity_codes"]["import_count"]}"

        CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
          code = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
          content = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
          
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
    task :purchase_orders, [:import_path] => :environment do |t, args|
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      
      csv_folder = args[:import_path] ? ("/Users/sufu/code/rails/fraefel" + "/import/csv/") : "/home/ivo/csv/"
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
          customer = Customer.find_by_baan_id(Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip)
          baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
          csv_customer = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip
          delivery_route = ShippingRoute.find_by_name(Iconv.conv('UTF-8', 'iso-8859-1', row[21]).to_s.chomp.lstrip.rstrip)
        
          purchase_order = PurchaseOrder.find_or_initialize_by_baan_id(:baan_id => baan_id, :customer => customer, :status => "open", :shipping_route => delivery_route)
          if purchase_order.present? && purchase_order.new_record?
            if purchase_order.save
              #puts "New Purchase Order has been created: #{purchase_order.attributes}"
            else
              puts "ERROR-- PurchaseOrder not saved..."
            end
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
    task :purchase_positions, [:import_path] => :environment do |t, args|
      PaperTrail.whodunnit = 'System'
      
      import_yaml = YAML.load_file("import/import.yml")
      
      csv_folder = args[:import_path] ? ("/Users/sufu/code/rails/fraefel" + "/import/csv/") : "/home/ivo/csv/"
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
          baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
          commodity_code = CommodityCode.find_by_code(Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip)
          purchase_order = PurchaseOrder.find_by_baan_id(baan_id)
          weight_single = Iconv.conv('UTF-8', 'iso-8859-1', row[15]).to_s.chomp.lstrip.rstrip.to_f
          weight_total = Iconv.conv('UTF-8', 'iso-8859-1', row[16]).to_s.chomp.lstrip.rstrip.to_f
          quantity = Iconv.conv('UTF-8', 'iso-8859-1', row[18]).to_s.chomp.lstrip.rstrip.to_f
          amount = Iconv.conv('UTF-8', 'iso-8859-1', row[17]).to_s.chomp.lstrip.rstrip.to_f
          position = Iconv.conv('UTF-8', 'iso-8859-1', row[4]).to_s.chomp.lstrip.rstrip.to_i
          delivery_date = Iconv.conv('UTF-8', 'iso-8859-1', row[13]).to_s.chomp.lstrip.rstrip
          article = Iconv.conv('UTF-8', 'iso-8859-1', row[28]).to_s.chomp.lstrip.rstrip
          article_number = Iconv.conv('UTF-8', 'iso-8859-1', row[27]).to_s.chomp.lstrip.rstrip
          product_line = Iconv.conv('UTF-8', 'iso-8859-1', row[30]).to_s.chomp.lstrip.rstrip
          storage_location = Iconv.conv('UTF-8', 'iso-8859-1', row[23]).to_s.chomp.lstrip.rstrip
          consignee_full = Iconv.conv('UTF-8', 'iso-8859-1', row[33]).to_s.chomp.lstrip.rstrip
          if !consignee_full.present?
            puts "Warning -- No consignee in CSV"
          end
          calculated_amount = amount * quantity
          if purchase_order.purchase_positions.where(:position => position).present?
            purchase_position = purchase_order.purchase_positions.where(:position => position).first
            csv_array = [weight_single.to_s, weight_total.to_s, quantity.to_s, amount.to_s, position, delivery_date]
            purchase_position_array = [purchase_position.weight_single.to_s, purchase_position.weight_total.to_s, purchase_position.quantity.to_s, purchase_position.amount.to_s, purchase_position.position, purchase_position.delivery_date]
            if (csv_array != purchase_position_array && purchase_position.status == "open")
              if purchase_position.pallet.present?
                purchase_position.update_attributes(:article => article, :delivery_date => delivery_date, :product_line => product_line, :storage_location => storage_location, :article_number => article_number, :consignee_full => consignee_full)
                puts purchase_position.consignee_full
              else
                purchase_position.update_attributes(:commodity_code => commodity_code, :weight_single => weight_single, :weight_total => weight_total, :quantity => quantity, :amount => amount, :position => position, :status => "open", :article => article, :delivery_date => delivery_date, :product_line => product_line, :storage_location => storage_location, :article_number => article_number, :total_amount => calculated_amount, :consignee_full => consignee_full)
                puts purchase_position.consignee_full
              end
            else
            end
            purchase_position.update_attributes(:consignee_full => consignee_full)
          else
            purchase_position = purchase_order.purchase_positions.build(:commodity_code => commodity_code, :weight_single => weight_single, :weight_total => weight_total, :quantity => quantity, :amount => amount, :position => position, :status => "open", :delivery_date => delivery_date, :article => article, :product_line => product_line, :storage_location => storage_location, :article_number => article_number, :total_amount => calculated_amount, :consignee_full => consignee_full)
            if purchase_position.save
              puts purchase_position.consignee_full
              #puts "New Purchase Position has been created: #{purchase_position.attributes}"
            else
              puts "ERROR-- PurchasePosition not saved..."
            end
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
    
    desc "Load Delivery Routes from CSV into Database"
    task :shipping_routes, [:import_path] => :environment do |t, args|
      PaperTrail.whodunnit = 'System'
      
      csv_folder = args[:import_path] ? ("/Users/sufu/code/rails/fraefel" + "/import/csv/") : "/home/ivo/csv/"
      csv_file = Dir[File.join(csv_folder, 'BaanRead_Versand.csv')]
      
      CSV.foreach(csv_file[0], {:col_sep => ";", :headers => :first_row}) do |row|
        delivery_route = Iconv.conv('UTF-8', 'iso-8859-1', row[21]).to_s.chomp.lstrip.rstrip
      
        shipping_route = ShippingRoute.find_or_initialize_by_name(:name => delivery_route, :active => true)
        if shipping_route.present? && shipping_route.new_record? && shipping_route.name.present?
          shipping_route.save
          puts "New ShippingRoute has been created: #{shipping_route.attributes}"
        end
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
      #csv_folder = File.join(Rails.root, "import/csv/users/")
      #csv_file = Dir[File.join(csv_folder, 'BaanRead_Benutzer.csv')]
      
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
    
    desc "Run all Imports --> this will reset your data!"
    task :complete => [:reset, :default_data, :customers, :shipping_addresses, :users, :commodity_codes, :shipping_routes, :purchase_orders, :purchase_positions] do
    end
    
    desc "Re-Import"
    task :re => [:customers, :shipping_addresses, :users, :commodity_codes, :shipping_routes, :purchase_orders, :purchase_positions] do
    end
    
    desc "Update-MD5"
    task :update_md5 => :environment do
      import_yaml = YAML.load_file("import/import.yml")
      
      import_yaml["csv"]["users"]["checksum"] = Digest::SHA1.hexdigest(File.read("import/csv/users/BaanRead_Benutzer.csv"))
      import_yaml["csv"]["customers"]["checksum"] = Digest::SHA1.hexdigest(File.read("import/csv/purchase_orders/BaanRead_Versand.csv"))
      import_yaml["csv"]["shipping_addresses"]["checksum"] = Digest::SHA1.hexdigest(File.read("import/csv/purchase_orders/BaanRead_Versand.csv"))
      import_yaml["csv"]["commodity_codes"]["checksum"] = Digest::SHA1.hexdigest(File.read("import/csv/purchase_orders/BaanRead_Versand.csv"))
      import_yaml["csv"]["purchase_orders"]["checksum"] = Digest::SHA1.hexdigest(File.read("import/csv/purchase_orders/BaanRead_Versand.csv"))
      import_yaml["csv"]["purchase_positions"]["checksum"] = Digest::SHA1.hexdigest(File.read("import/csv/purchase_orders/BaanRead_Versand.csv"))
      
      puts "Update CONFIG_FILE..."
      File.open("#{RAILS_ROOT}/import/import.yml", 'w') { |f| YAML.dump(import_yaml, f) }
    end
    
    desc "Developer Re-Import"
    task :developer_re => :environment do
      Rake.application.invoke_task("baan:import:customers['/import/csv/']")
      Rake.application.invoke_task("baan:import:shipping_addresses['/import/csv/']")
      Rake.application.invoke_task("baan:import:users['/import/csv/']")
      Rake.application.invoke_task("baan:import:commodity_codes['/import/csv/']")
      Rake.application.invoke_task("baan:import:shipping_routes['/import/csv/']")
      Rake.application.invoke_task("baan:import:purchase_orders['/import/csv/']")
      Rake.application.invoke_task("baan:import:purchase_positions['/import/csv/']")
    end
    
    
  end
end
