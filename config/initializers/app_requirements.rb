require 'iconv'

class String
  def undress
    self.force_encoding('iso-8859-1').encode('utf-8').chomp.lstrip.rstrip
  end
end

Ransack.configure do |config|
  config.add_predicate 'equals', :arel_predicate => 'eq', :validator => proc {|v| v.present?}
end
