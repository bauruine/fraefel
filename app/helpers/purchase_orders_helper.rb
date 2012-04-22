module PurchaseOrdersHelper
  
  def title_for_purchase_position(*args)
    purchase_position = args[0]
    purchase_order = args[1]
    
    if permitted_to? :remove_positions, :pallets
      if purchase_position.in_mixed_pallet?(purchase_order)
        link_to("M-#{purchase_position.try(:purchase_order).try(:baan_id)}-#{purchase_position.position}", edit_purchase_position_path(purchase_position), "data-role" => "edit_remote")
      else
        link_to(purchase_position.position, edit_purchase_position_path(purchase_position), "data-role" => "edit_remote")
      end
    else
      if purchase_position.in_mixed_pallet?(purchase_order)
        "M-#{purchase_position.try(:purchase_order).try(:baan_id)}-#{purchase_position.position}"
      else
        purchase_position.position
      end
    end
  end
  
end
