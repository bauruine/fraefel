# encoding: utf-8

class StocktakingsController < FraefelController

  def index

  end

  def export

  end

  def new
    @stocktaking = Stocktaking.new
  end

  def create
    @stocktaking = Stocktaking.new
  end

end
