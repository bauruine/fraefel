module ApplicationHelper
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to(name, '#', :class => "add_fields", "data-id" => id, "data-fields" => fields.gsub("\n", ""))
  end
  
  def filter_url(params, *filter_args)
    params = params
    filter_args = filter_args.first
    
    if params[:search].present?
      params[:search].merge!(filter_args)
    else
      params.merge!(:search => filter_args)
    end
    
    url_for(params)
  end
  
  def boolean_buttler(params, *filter_args)
  end
  
  def prio_title(number)
    prio_level = number.to_s
    @prio_hash = {"0" => "TS Aktiv", "1" => "Normal", "2" => "Termin verschoben"}
    return @prio_hash[prio_level]
  end
  
	# returns "active" if in @search
	def active_department?(requested_department, department_id)
		# puts requested_department + "   #{department_id}"
		if requested_department.to_i == department_id.to_i then 
			return "active"
		end
	rescue
		return ""
	end
end
