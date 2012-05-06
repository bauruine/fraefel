collection @purchase_orders

node(:id) do |purchase_order|
  purchase_order.id
end

node(:c_0) do |purchase_order|
  link_to(purchase_order.baan_id, purchase_order_path(purchase_order))
end

node(:c_1) do |purchase_order|
  "#{purchase_order.stock_status} / #{purchase_order.calculation.try(:total_purchase_positions)}"
end

node(:c_2) do |purchase_order|
  purchase_order.calculation.total_pallets
end

node(:c_3) do |purchase_order|
  purchase_order.purchase_positions.try(:first).try(:consignee_full)
end

node(:c_4) do |purchase_order|
  purchase_order.try(:shipping_route).try(:name)
end

node(:c_5) do |purchase_order|
  purchase_order.purchase_positions.first.try(:zip_location_name)
end

node(:c_6) do |purchase_order|
  purchase_order.delivery_date.to_formatted_s(:swiss_date)
end