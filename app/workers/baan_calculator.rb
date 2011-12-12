class BaanCalculator
  @queue = :baan_calculator_queue
  def self.perform(group_to_calculate)
    Article.calculate_difference(group_to_calculate)
  end
end