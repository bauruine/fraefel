module CargoListsHelper
  def pdf_title(cargo_list_id, title)
    return "versand-#{CargoList.find(cargo_list_id).id}-#{CargoList.find(cargo_list_id).pick_up_time_earliest.to_date.to_formatted_s(:pdf)}-#{title}"
  end
end
