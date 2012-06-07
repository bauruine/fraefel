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
  
end
