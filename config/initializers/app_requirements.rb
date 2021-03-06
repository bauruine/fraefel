class String
  def undress
    self.chomp.lstrip.rstrip
  end
  
  def to_md5
    return Digest::MD5.hexdigest(dup)
  end
end

class Hash
  def to_tag_options
    options = self
    escape = true
    unless options.blank?
      attrs = []
      options.each_pair do |key, value|
        if key.to_s == 'data' && value.is_a?(Hash)
          value.each do |k, v|
            if !v.is_a?(String) && !v.is_a?(Symbol)
              v = v.to_json
            end
            v = ERB::Util.html_escape(v) if escape
            attrs << %(data-#{k.to_s.dasherize}="#{v}")
          end
        elsif ActionView::Helpers::BOOLEAN_ATTRIBUTES.include?(key)
          attrs << %(#{key}="#{key}") if value
        elsif !value.nil?
          final_value = value.is_a?(Array) ? value.join(" ") : value
          final_value = ERB::Util.html_escape(final_value) if escape
          attrs << %(#{key}="#{final_value}")
        end
      end
      " #{attrs.sort * ' '}".html_safe unless attrs.empty?
    end
  end
  
  def to_md5(*except_keys)
    return Digest::MD5.hexdigest(dup.except!(*except_keys).to_s)
  end
  
end


Ransack.configure do |config|
  config.add_predicate 'equals', :arel_predicate => 'eq', :validator => proc {|v| v.present?}
end
