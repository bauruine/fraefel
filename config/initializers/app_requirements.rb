require 'iconv'

class String
  def undress
    self.chomp.lstrip.rstrip
  end
end

Ransack.configure do |config|
  config.add_predicate 'equals', :arel_predicate => 'eq', :validator => proc {|v| v.present?}
end
