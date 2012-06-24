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
  
  def aggregation_for(purchase_order_id)
    @purchase_order = PurchaseOrder.where(:id => purchase_order_id)
    @purchase_order_attributes = {:purchase_order => {}}
    
    if @purchase_order.present?
      @purchase_order = @purchase_order.first
      @purchase_positions = @purchase_order.purchase_positions
      @sum_production_status, @sum_stock_status, @count_purchase_positions = @purchase_positions.sum(:production_status), @purchase_positions.sum(:stock_status), @purchase_positions.count.to_f
      @purchase_order_attributes[:purchase_order].merge!(:manufacturing_completed => @sum_production_status * (100.to_f / @count_purchase_positions))
      @purchase_order_attributes[:purchase_order].merge!(:warehousing_completed => @sum_stock_status * (100.to_f / @count_purchase_positions))
      @purchase_order_attributes[:purchase_order].merge!(:pending_status => @count_purchase_positions - @sum_production_status)
      @purchase_order_attributes[:purchase_order].merge!(:production_status => @sum_production_status)
      @purchase_order_attributes[:purchase_order].merge!(:stock_status => @sum_stock_status)
      @purchase_order_attributes[:purchase_order].merge!(:workflow_status => "#{@sum_production_status}#{@sum_stock_status}")
    end
    return @purchase_order_attributes
  end
  
end
