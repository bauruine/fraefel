class BaanCalculator

  include Sidekiq::Worker

  sidekiq_options queue: "baan_calculator_queue"
  sidekiq_options retry: false

  def perform(group_to_calculate)
    Article.calculate_difference(group_to_calculate)
  end

end
