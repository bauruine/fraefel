module PurchaseOrdersHelper
  
  # WARNING!!!! UBER extreme UGLY CODAAAAAAAAA. Buhahahaha!!
  def title_for_purchase_position(*args)
    purchase_position = args[0]
    purchase_order = args[1]
    
    if permitted_to? :remove_positions, :pallets
      if purchase_position.in_mixed_pallet?(purchase_order)
        attrs = String.new
        attrs << %(<div class="btn-group">)
        attrs << %(<span class="btn btn-mini disabled btn-#{purchase_position.production_status}#{purchase_position.stock_status}">)
        attrs << %(#{purchase_position.try(:purchase_order).try(:baan_id)}-#{purchase_position.position})
        attrs << %(</span>)
        
        attrs << %(<span class="btn btn-mini disabled">)
        attrs << %(<i class="icon-retweet"></i>)
        attrs << %(</span>)
        
        attrs << %(</div>)
        
        attrs.html_safe
      else
        link_to(purchase_position.baan_id, "#purchase_position_#{purchase_position.id}", "data-toggle" => "modal", :class => "btn btn-mini btn-#{purchase_position.production_status}#{purchase_position.stock_status}")
      end
    else
      if purchase_position.in_mixed_pallet?(purchase_order)
        attrs = String.new
        attrs << %(<div class="btn-group">)
        attrs << %(<span class="btn btn-mini disabled btn-#{purchase_position.production_status}#{purchase_position.stock_status}">)
        attrs << %(#{purchase_position.try(:purchase_order).try(:baan_id)}-#{purchase_position.position})
        attrs << %(</span>)
        
        attrs << %(<span class="btn btn-mini disabled">)
        attrs << %(<i class="icon-retweet"></i>)
        attrs << %(</span>)
        
        attrs << %(</div>)
        
        attrs.html_safe
      else
        attrs = String.new
        attrs << %(<div class="btn-group">)
        attrs << %(<span class="btn btn-mini disabled btn-#{purchase_position.production_status}#{purchase_position.stock_status}">)
        attrs << %(#{purchase_position.try(:purchase_order).try(:baan_id)}-#{purchase_position.position})
        attrs << %(</span>)
        
        attrs << %(</div>)
        
        attrs.html_safe
      end
    end
  end
  
end
