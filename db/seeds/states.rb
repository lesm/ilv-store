# frozen_string_literal: true

country = Country.find_or_create_by!(name: 'México', code: 'MX')

Country::MX_STATES.each do |state_name|
  Country::State.find_or_create_by!(
    name: state_name[:name], code: state_name[:code], country:
  )
end
