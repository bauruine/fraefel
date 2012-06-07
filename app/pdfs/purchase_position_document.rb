class PurchasePositionDocument < Prawn::Document
  def initialize()
    super(top_margin: 5, page_layout: :landscape, page_size: 'A4')
    #@purchase_positions = purchase_positions
    #@view = view
    font_size 7
    @purchase_positions = PurchasePosition.where(:delivered => false).includes(:pallets, :commodity_code, :purchase_order => :shipping_route).limit(30)
    order_number
    line_items
    #total_price
  end
  
  def order_number
    text "PurchasePositions \#", size: 30, style: :bold
  end
  
  def line_items
    move_down 20
    table line_item_rows do
      row(0).font_style = :bold
      columns(1..3).align = :right
      self.row_colors = ["DDDDDD", "FFFFFF"]
      self.header = true
      self.width = 769.89
    end
  end

  def line_item_rows
    [["Versand", "Tour", "VK-Pos", "Artikel", "stk.", "Bezeichnung", "Produktlinie", "Lager Ort", "Palette"]] +
    @purchase_positions.map do |purchase_position|
      [
        purchase_position.delivery_date.to_date.to_formatted_s(:swiss_date),
        purchase_position.purchase_order.shipping_route.name,
        purchase_position.baan_id,
        purchase_position.article_number,
        purchase_position.quantity,
        purchase_position.article,
        purchase_position.product_line,
        purchase_position.storage_location,
        purchase_position.pallets.collect(&:id).join(", ")
      ]
    end
  end
  
end