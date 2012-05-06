require 'iconv'

class String
  def undress
    self.force_encoding('iso-8859-1').encode('utf-8').chomp.lstrip.rstrip
  end
end

Rabl.configure do |config|
  config.include_json_root = false
end