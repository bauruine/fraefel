# encoding: utf-8
class DeliveryRejectionProformaInvoiceDocument < Prawn::Document
  def initialize(args)
    super(top_margin: 5, page_layout: :portrait, page_size: 'A4')
    delivery_rejection_id = args[:delivery_rejection_id]
    @delivery_rejection = DeliveryRejection.where(:id => delivery_rejection_id).first
    level_3_id = args[:level_3]
    @level_3 = Address.where(:id => level_3_id).first
    @level_3 ||= Address.where(:id => 1447).first

    @delivery_address = @delivery_rejection.delivery_address
    @invoice_address = @delivery_rejection.invoice_address
    @pick_up_address = @delivery_rejection.pick_up_address
    
    #@address_category = Category.where(:title => "kat_c").first
    #@invoice_address_category_id = Category.where(:title => "kat_b").first
    #@address = Address.where("cargo_lists.id = ?", @cargo_list.id).where("addresses.category_id = ?", @address_category.id).includes(:purchase_orders => [:pallets => :cargo_list]).first
    #@invoice_address = Address.where("cargo_lists.id = ?", @cargo_list.id).where("addresses.category_id = ?", @invoice_address_category_id.id).includes(:purchase_orders => [:pallets => :cargo_list]).first
    @purchase_positions = PurchasePosition.where("delivery_rejections.id = ?", @delivery_rejection.id).includes(:pallets => :delivery_rejection)
    @pallet_purchase_position_assignments = PalletPurchasePositionAssignment.where("delivery_rejections.id = ?", @delivery_rejection.id).includes(:pallet => [:delivery_rejection], :purchase_position => [:commodity_code])
    @pallets = Pallet.where("delivery_rejections.id = ?", @delivery_rejection.id).includes(:delivery_rejection)
    @pallet_types = PalletType.where("delivery_rejections.id = ?", @delivery_rejection.id).includes(:pallets => :delivery_rejection)
    
    font_size 8
    #move_down 97
    bounding_box [0, 665], :width => 261.64, :height => 200 do
      invoice_address
      #stroke_bounds
    end
    bounding_box [261.64, 665], :width => 261.64, :height => 200 do
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
      ["Fraefel AG", ""],
      ["Lerchenfeld", ""],
      ["CH-9601 Lütisburg-Station", ""],
      ["Eori Nr. DE 893514633232115", ""]
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
      ["Firma:", "#{@delivery_address.try(:company_name)}"],
      ["Strasse/Nr:", "#{@delivery_address.try(:street)}"],
      ["Postleitzahl:", "#{@delivery_address.try(:postal_code)}"],
      ["Ort:", "#{@delivery_address.try(:city)}"],
      ["Land:", "#{@delivery_address.try(:country)}"]
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
      ["Firma:", "#{@pick_up_address.try(:company_name)}"],
      ["Strasse/Nr:", "#{@pick_up_address.try(:street)}"],
      ["Postleitzahl:", "#{@pick_up_address.try(:postal_code)}"],
      ["Ort:", "#{@pick_up_address.try(:city)}"],
      ["Land:", "#{@pick_up_address.try(:country)}"],
      ["", ""],
      ["", ""]
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
        "#{((@pallet_purchase_position_assignments.where("commodity_codes.id = ?", k).sum(:amount) / 100) * 10).round(2)}"
      ]
    end
  end
  
  def foobar2_items
    [
      ["", "", "", "Rechnungswert", "#{((@pallet_purchase_position_assignments.sum(:amount) / 100) * 10).round(2)}"],
      ["", "", "", "Währung", "EUR"]
    ]
  end
  
  def foobar3_items
    [
      ["Transport:", "per LKW", "Lieferbedingung:", "frei Haus, unverzollt"],
      ["Netto Gewicht (kg):", "#{@pallet_purchase_position_assignments.sum(:weight) }", "U/Z:", "RV #{@delivery_rejection.id} / #{Date.today.to_formatted_s(:swiss_date)}"],
      ["Brutto Gewicht (kg):", "#{@pallet_purchase_position_assignments.sum(:weight) + (@pallet_types.sum(:count_as) * 20)}", "", ""],
      ["Paletten:", "#{@pallets.count}", "", ""],
      ["Paletten Plätze:", "#{@pallet_types.sum(:count_as)}", "", ""],
      ["Coli:", "#{@pallet_types.where("pallet_types.description = ?", "coli").count}", "", ""]
    ]
  end
  
  def foobar4_items
    [
      ["Ort / Datum:", "#{Date.today.to_formatted_s(:swiss_date)}", "Unterschrift:", ""],
      ["", "", "", ""],
      ["", "", "Name:", ""]
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
    text "Der Ausführer der Waren, auf die sich dieses", style: :bold
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
      row(1).height = 20
      row(2).columns(3).borders = [:bottom]
    end
    
  end
  
end
