# encoding: utf-8
class ProformaInvoiceDocument < Prawn::Document
  def initialize(args)
    super(top_margin: 5, page_layout: :portrait, page_size: 'A4')
    cargo_list_id = args[:cargo_list_id]
    @cargo_list = CargoList.where(:id => cargo_list_id).first
    @address_category = Category.where(:title => "kat_c").first
    @invoice_address_category_id = Category.where(:title => "kat_b").first
    @address = Address.where("cargo_lists.id = ?", @cargo_list.id).where("addresses.category_id = ?", @address_category.id).includes(:purchase_orders => [:pallets => :cargo_list]).first
    @invoice_address = Address.where("cargo_lists.id = ?", @cargo_list.id).where("addresses.category_id = ?", @invoice_address_category_id.id).includes(:purchase_orders => [:pallets => :cargo_list]).first
    @purchase_positions = PurchasePosition.where("cargo_lists.id = ?", @cargo_list.id).includes(:pallets => :cargo_list)
    @pallet_purchase_position_assignments = PalletPurchasePositionAssignment.where("cargo_lists.id = ?", @cargo_list.id).includes(:pallet => [:cargo_list], :purchase_position => [:commodity_code])
    @pallets = Pallet.where("cargo_lists.id = ?", @cargo_list.id).includes(:cargo_list)
    @pallet_types = PalletType.where("cargo_lists.id = ?", @cargo_list.id).includes(:pallets => :cargo_list)
    
    font_size 8
    #move_down 97
    bounding_box [0, 690], :width => 261.64, :height => 200 do
      invoice_address
      #stroke_bounds
    end
    bounding_box [261.64, 690], :width => 261.64, :height => 200 do
      delivery_address
      move_down 14
      address_of_sender
      #stroke_bounds
    end
    proforma_invoice
    shipment_data
    shipment_declaration
  end
  
  def invoice_address
    text "Rechnungs Adresse", style: :bold
    move_down 11
    table invoice_address_table do
      self.width = 261.64
      self.cell_style = { :padding_left => 0, :padding_top => 1, :padding_bottom => 1, :borders => [] }
      row(0).columns(0).font_style = :bold
    end
  end
  
  def invoice_address_table
    [
      ["Schweizerbad GmbH", ""],
      ["Hochfeilerweg 48a", ""],
      ["12107 Berlin", ""],
      ["Deutschland", ""]
    ]
    
  end
  
  def delivery_address
    text "Liefer Adresse", style: :bold
    move_down 11
    
    table delivery_address_table do
      self.width = 261.64
      self.cell_style = { :padding_left => 0, :padding_top => 1, :padding_bottom => 1, :borders => [] }
      column(0).width = 80
    end
  end
  
  def delivery_address_table
    [
      ["Firma:", "#{@address.company_name}"],
      ["Strasse/Nr:", "#{@address.street}"],
      ["Postleitzahl:", "#{@address.postal_code}"],
      ["Ort:", "#{@address.city}"],
      ["Land:", "Deutschland"]
    ]
  end
  
  def address_of_sender
    text "Sender Adresse", style: :bold
    move_down 11
    
    table address_of_sender_table do
      self.width = 261.64
      self.cell_style = { :padding_left => 0, :padding_top => 1, :padding_bottom => 1, :borders => [] }
      column(0).width = 80
    end
    
  end
  
  def address_of_sender_table
    [
      ["Firma:", " Fraefel AG"],
      ["Strasse/Nr:", "Lerchenfeld"],
      ["Postleitzahl:", "9601"],
      ["Ort:", "Lütisburg-Station"],
      ["Land:", "Schweiz"],
      ["Telefon:", "+41 71 982 80 80"],
      ["EORI Nr.:", "DE 7662858"]
    ]
  end
  
  def proforma_invoice
    table [["Proforma Rechnung", "Nur für Zollzwecke."], ["Rechnungs Datum:", "#{Date.today.to_formatted_s(:swiss_date)}"]] do
      self.width = 523.28
      self.cell_style = { :padding_left => 0, :borders => [] }
      
      row(0).columns(0).font_style = :bold
      column(0).width = 130
      #row(1).width = 423.28
    end
    stroke_horizontal_rule
    move_down 10
    
    table [["Warenbezeichnung", "Warentarifnummer", "Stk.", "Gewicht", "Warenwert"]] + foobar_items + foobar2_items do
      row(0).font_style = :bold
      row(0).columns(0..7).padding = [0, 5, 0, 0]
      
      self.width = 523.28
      self.cell_style = { :padding_left => 0, :borders => [] }
      
      row(self.row_length - 2).columns(3).font_style = :bold
      row(self.row_length - 1).columns(3).font_style = :bold
      
    end
    stroke_horizontal_rule
    
  end
  
  def foobar_items
    @purchase_positions.group(:commodity_code_id).count.map do |k, v|
      [
        "#{CommodityCode.find(k).content}",
        "#{CommodityCode.find(k).code}",
        "#{@pallet_purchase_position_assignments.where("commodity_codes.id = ?", k).sum(:quantity) }",
        "#{@pallet_purchase_position_assignments.where("commodity_codes.id = ?", k).sum(:weight) }",
        "#{@pallet_purchase_position_assignments.where("commodity_codes.id = ?", k).sum(:amount) }"
      ]
    end
  end
  
  def foobar2_items
    [
      ["", "", "", "Rechnungswert", "#{@pallet_purchase_position_assignments.sum(:amount) }"],
      ["", "", "", "Währung", "EUR"]
    ]
  end
  
  def foobar3_items
    [
      ["Transport:", "Lebert", "Lieferbedingung:", "frei Haus, verzollt, versteuert (DDP)"],
      ["Netto Gewicht (kg):", "#{@pallet_purchase_position_assignments.sum(:weight) }", "Versand Nr.:", "#{@cargo_list.id}"],
      ["Brutto Gewicht (kg):", "#{@pallet_purchase_position_assignments.sum(:weight) + (@pallet_types.sum(:count_as) * 20)}", "", ""],
      ["Paletten:", "0", "", ""],
      ["Paletten Plätze:", "#{@pallet_types.sum(:count_as)}", "", ""],
      ["Coli:", "#{@pallet_types.where("pallet_types.description = ?", "coli").count}", "", ""]
    ]
  end
  
  def foobar4_items
    [
      ["Ort / Datum:", "Lütisburg-Station / #{Date.today.to_formatted_s(:swiss_date)}", "Unterschrift:", ""],
      ["", "", "Name:", "#{User.current.full_name}"]
    ]
  end
  
  def shipment_data
    move_down 10
    
    text "Versand Daten", style: :bold
    
    move_down 10
    
    table foobar3_items do
      self.width = 523.28
      self.cell_style = { :padding_left => 0, :padding_bottom => 0, :padding_top => 3, :borders => [] }
      column(0).width = 130
      row(0).columns(1).font_style = :bold
    end
    
    move_down 5
    stroke_horizontal_rule
  end
  
  def shipment_declaration
    move_down 10
    text "Der Ausführer ( Ermächtigter Ausführer; Bewilligungs-Nr.4218 ) der Waren, auf die sich dieses", style: :bold
    move_down 5
    text "Handelspapier bezieht, erklärt, dass diese Waren, soweit nicht anders angegeben, präferenzbegünstigte", style: :bold
    move_down 5
    text "schweizerische Ursprungswaren sind.", style: :bold
    move_down 15
    
    table foobar4_items do
      self.width = 523.28
      self.cell_style = { :padding_left => 0, :padding_bottom => 0, :padding_top => 3, :borders => [] }
      column(0).width = 130
      row(0).columns(3).borders = [:bottom]
    end
    
  end
  
end