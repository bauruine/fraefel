class FraefelJaintor
  @queue = :fraefel_jaintor_queue
  def self.perform
    PurchaseOrder.clean
  end
end