class PurchaseOrdersDocument < Prawn::Document
  def initialize(args)
    super(top_margin: 5, page_layout: :landscape, page_size: 'A4')
    font_size 7
    
    # Load Data for printing
    @search = PurchaseOrder.search(args[:q])
    @addresses = Address.select("DISTINCT `addresses`.id").where(:category_id => 10, "purchase_orders.id" => @search.result.collect(&:id)).joins(:purchase_orders).order("purchase_orders.delivery_date ASC")
    @purchase_orders = @search.result
    
    order_number
    line_items
    #total_price
  end
  
  def order_number
    text "PurchasePositions \#", size: 30, style: :bold
  end
  
  def line_items
    move_down 20
    @addresses.each do |address|
    
      table line_item_rows(address) do
        row(0).font_style = :bold
        columns(1..3).align = :right
        self.row_colors = ["DDDDDD", "FFFFFF"]
        self.header = true
        self.width = 769.89
      end
    end
  end

  def line_item_rows(arg)
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
