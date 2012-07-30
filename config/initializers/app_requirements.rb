require 'iconv'

class String
  def undress
    self.force_encoding('iso-8859-1').encode('utf-8').chomp.lstrip.rstrip
  end
end
