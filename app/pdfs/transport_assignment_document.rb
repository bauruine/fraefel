# encoding: utf-8
class TransportAssignmentDocument < Prawn::Document
  def initialize(args)
    super(top_margin: 5, page_layout: :portrait, page_size: 'A4')
    cargo_list_id = args[:cargo_list_id]
    @cargo_list = CargoList.where(:id => cargo_list_id).first
    @address_category = Category.where(:title => "kat_c").first
    @invoice_address_category_id = Category.where(:title => "kat_b").first
    @address = Address.where("cargo_lists.id = ?", @cargo_list.id).where("addresses.category_id = ?", @address_category.id).includes(:purchase_orders => [:pallets => :cargo_list]).first
    @purchase_positions = PurchasePosition.where("cargo_lists.id = ?", @cargo_list.id).includes(:pallets => :cargo_list)
    @commodity_codes = CommodityCode.where("cargo_lists.id = ?", @cargo_list.id).includes(:purchase_positions => [:pallets => :cargo_list])
    @pallet_purchase_position_assignments = PalletPurchasePositionAssignment.where("cargo_lists.id = ?", @cargo_list.id).includes(:pallet => [:cargo_list], :purchase_position => [:commodity_code])
    @pallets = Pallet.where("cargo_lists.id = ?", @cargo_list.id).includes(:cargo_list)
    @pallet_types = PalletType.where("cargo_lists.id = ?", @cargo_list.id).includes(:pallets => :cargo_list)
    
    font_size 8
    move_down 97
    bounding_box [0, 690], :width => 261.64, :height => 70 do
      section_1_left
      #stroke_bounds
    end
    bounding_box [261.64, 690], :width => 261.64, :height => 70 do
      section_1_right
      #stroke_bounds
    end
    move_down 10
    stroke_horizontal_rule
    move_down 10
    section_2
    move_down 10
    stroke_horizontal_rule
    move_down 10
    section_3
    move_down 10
    stroke_horizontal_rule
    move_down 10
    transport_assignment_footer
  end
  
  def section_1_left
    table section_1_left_table do
      self.width = 261.64
      self.cell_style = { :padding_left => 0, :padding_top => 1, :padding_bottom => 1, :borders => [] }
      row(0).columns(0).font_style = :bold
      row(0).columns(0).size = 15
    end
  end
  
  def section_1_left_table
    [
      ["TRANSPORTAUFTRAG"],
      [""],
      [""],
      ["an:"],
      ["mail:"]
    ]
  end
  
  def section_1_right
    table section_1_right_table do
      self.width = 261.64
      self.cell_style = { :padding_left => 0, :padding_top => 1, :padding_bottom => 1, :borders => [] }
      row(0).columns(0).font_style = :bold
      row(0).columns(0).size = 13
    end
  end
  
  def section_1_right_table
    [
      ["Delacher-Logwin"],
      [""],
      [""],
      ["Delacher-Logwin"],
      ["dominik.schmid@jcl-logistics.com"],
      ["dominik.schmid@jcl-logistics.com"]
    ]
  end
  
  def section_2
    table section_2_table do
      self.cell_style = { :padding_left => 0, :padding_top => 1, :padding_bottom => 1, :borders => [] }
      column(0).width = 261.64
      self.width = 523.28
    end
  end
  
  def section_2_table
    [
      ["Ladestelle:", ""],
      ["", "Lerchenfeld"],
      ["", "9601 Lütisburg-Station"],
      ["Kontaktperson:", "D. Di Cataldo Tel: 071 982 80 84"],
      ["abholbereit ab:", "#{@cargo_list.pick_up_time_earliest.to_date.to_formatted_s(:swiss_date)} Zeit: ab #{@cargo_list.pick_up_time_earliest.to_formatted_s(:hour_and_minute)} Uhr"]
    ]
  end
  
  def section_3
    table section_3_table do
      self.cell_style = { :padding_left => 0, :padding_top => 1, :padding_bottom => 1, :borders => [] }
      self.width = 523.28
      row(0).height = 20
      row(0).font_style = :bold
    end
  end
  
  def section_3_table
    [
      ["Lieferadresse:", "Paletten", "Paletten Plätze", "Stk.", "Netto kg", "Brutto kg", "Total CHF", "Total EUR"],
      ["#{@address.company_name}", "", "", "", "", "", "", ""],
      [
        "#{@address.company_name}", "#{@pallets.count}",
        "#{@pallet_types.count}", "#{@pallet_purchase_position_assignments.sum(:quantity)}",
        "#{@pallet_purchase_position_assignments.sum(:weight)}",
        "#{@pallet_purchase_position_assignments.sum(:weight) + (@pallet_types.sum(:count_as) * 20)}",
        "",
        "#{@pallet_purchase_position_assignments.sum(:amount)}"
      ],
      ["#{@address.street}", "", "", "", "", "", "", ""],
      ["#{@address.postal_code} #{@address.city}", "", "", "", "", "", "", ""],
      ["#{@address.country}", "", "", "", "", "", "", ""]
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
      ["EORI Nr.:", "7662858"]
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
  
  def foobar4_items
    [
      ["Ort / Datum:", "Lütisburg-Station / #{Date.today.to_formatted_s(:swiss_date)}", "Unterschrift:", ""]
    ]
  end
  
  def transport_assignment_footer
    move_down 15
    text "Warennummer: #{@commodity_codes.collect(&:code).join(", ")}"
    move_down 15
    text "Rechnungskopien werden dem Frachführer mitgegeben."
    move_down 3
    text "Die Paletten dürfen nicht aufgestellt oder mit anderer ware belastet werden."
    move_down 15
    text "Mit freundlichen Grüssen"
    move_down 3
    text "FRAEFEL AG"
    move_down 10
    text "#{User.current.full_name}"
    move_down 1
    text "mailto: #{User.current.email}"
    move_down 1
    text "Direkt:"
    move_down 15
    text "Ware in einwandfreiem Zustand erhalten am:"
    move_down 15
    
    table foobar4_items do
      self.width = 523.28
      self.cell_style = { :padding_left => 0, :padding_bottom => 0, :padding_top => 3, :borders => [] }
      column(0).width = 130
      #row(0).columns(3).borders = [:bottom]
    end
    
  end
  
end