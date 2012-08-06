class PurchaseOrdersDocument < Prawn::Document
  def initialize(args)
    super(top_margin: 5, page_layout: :landscape, page_size: 'A4')
    font_size 7
    
    # Load Data for printing
    @search = PurchaseOrder.search(args[:q])
    @addresses = Address.select("DISTINCT `addresses`.*").where(:category_id => 10, "purchase_orders.id" => @search.result.collect(&:id)).joins(:purchase_orders).order("purchase_orders.delivery_date ASC")
    @purchase_orders = @search.result
    
     repeat :all do
      # header
      bounding_box [bounds.left, bounds.top], :width  => bounds.width do
          font "Helvetica"
          text "Here's My Fancy Header", :align => :center, :size => 25
          stroke_horizontal_rule
      end

      # footer
      bounding_box [bounds.left, bounds.bottom + 25], :width  => bounds.width do
          font "Helvetica"
          stroke_horizontal_rule
          move_down(5)
          text "And here's a sexy footer", :size => 16
      end
    end
    
    
    order_number
    line_items
    
  end
  
  def order_number
    text "PurchasePositions \#", size: 30, style: :bold
  end
  
  def line_items
    move_down 20
    @addresses.each do |address|
      table line_item_rows(address) do
        self.cell_style = { :borders => [] }
        row(0..1).font_style = :bold
        row(0).borders = []

        self.row_colors = ["F9F9F9", "FFFFFF"]
        self.header = true
        self.width = 769.89
        self.header = true
      end
    end
  end

  def line_item_rows(arg)
    [[{:content => arg.consignee_full, :colspan => 9}], ["Versand", "Tour", "VK-Pos", "Artikel", "stk.", "Bezeichnung", "Produktlinie", "Lager Ort", "Palette"]] +
    PurchasePosition.select("DISTINCT `purchase_positions`.*").where("purchase_orders.id" => @search.result.collect(&:id)).joins(:purchase_order).includes(:shipping_route).map do |purchase_position|
      [
        purchase_position.delivery_date.to_date.to_formatted_s(:swiss_date),
        purchase_position.shipping_route.name,
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
