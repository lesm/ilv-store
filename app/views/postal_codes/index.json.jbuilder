# frozen_string_literal: true

postal_code = @postal_codes.first

json.postal_code postal_code.postal_code
json.state do
  json.id postal_code.state_id
  json.name postal_code.state_name
end
json.city do
  json.id postal_code.city_id
  json.name postal_code.city_name
end
json.neighborhoods @postal_codes.map(&:neighborhood)
