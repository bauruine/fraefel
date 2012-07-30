class DashboardsController < ApplicationController
  def show
    @articles = Article.where(:considered => true)
    @user = current_user
    
    @pending_purchase_orders = PurchaseOrder.where(:delivered => false).joins(:shipping_address)
    @delivered_purchase_orders = PurchaseOrder.where(:delivered => true).joins(:shipping_address)
    
    @pending_purchase_positions = PurchasePosition.where(:delivered => false)
    @delivered_purchase_positions = PurchasePosition.where(:delivered => true)
    
    @pending_delivery_rejections = DeliveryRejection.order("delivery_rejections.id DESC")
    
    @bad_purchase_orders = PurchaseOrder.where(:delivered => false).where("delivery_date < ?", Date.today - 5.days)
    
    @article_rack_group_number_total = @articles.group(:rack_group_number).count.size
    @open_articles = @articles.where("in_stock IS NULL or in_stock = ''").count
    @finished_articles = @articles.where("in_stock IS NOT NULL").where("in_stock != ''").count
    @open_articles_by_group = @articles.where("in_stock IS NULL or in_stock = ''").group(:rack_group_number).count
  end
end
