class DashboardsController < ApplicationController
  def show
    @user = current_user
    @open_purchase_orders = PurchaseOrder.where(:delivered => false)
    @bad_purchase_orders = PurchaseOrder.where("delivery_date < #{Date.today - 1.day}")
    @delivered_purchase_orders = PurchaseOrder.where(:delivered => true)
    @article_rack_group_number_total = Article.group(:rack_group_number).count.size
    @open_articles = Article.count
  end
end
