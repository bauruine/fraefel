class PalletType < ActiveRecord::Base
  has_many :pallets

  def weight
    return self.count_as.to_f * 20
  end
end
