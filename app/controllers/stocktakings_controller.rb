class StocktakingsController < ApplicationController

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
