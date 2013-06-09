class FraefelWorker::PurchaseOrder::Patcher

  include Sidekiq::Worker

  sidekiq_options queue: "baan_importer_queue"
  sidekiq_options retry: true

  def perform(batch)
    PurchaseOrder.where(:baan_id => batch).each do |purchase_order|
      # INFO-1: Change picked_up && delivered if new child
      purchase_order.patch_picked_up
      purchase_order.patch_delivered
      purchase_order.patch_cancelled
      # END INFO-1
      purchase_order.recalculate_calculation_total_purchase_positions
      purchase_order.patch_aggregations
      purchase_order.patch_html_content
      purchase_order.patch_btn_cat_a
    end
  end

end
