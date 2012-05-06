collection @addresses

node(:id) do |address|
  address.id
end

node(:name) do |address|
  address.location_for_select
end