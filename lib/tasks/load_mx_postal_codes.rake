# frozen_string_literal: true

namespace :mx_postal_codes do
  desc 'Load MX postal codes from xlsx file'

  task :load, [:sheet_name] => :environment do |task, args|
    file_path = 'db/files/CPdescargaxls.zip'
    unzip_file_path = "#{Dir.tmpdir}/mx_postal_codes.xls"

    unless File.exist?(unzip_file_path)
      Zip::File.open(file_path) do |zip_file|
        zip_file.each do |entry|
          entry.extract(unzip_file_path)
        end
      end
    end

    xlsx = Roo::Spreadsheet.open(unzip_file_path)

    columns = {
      postal_code: 'd_codigo', neighborhood: 'd_asenta', city: 'D_mnpio', state_name: 'd_estado'
    }

    states = Country::State.all.map.with_object({}) do |state, object|
      object[state.name.downcase] = { id: state.id, code: state.code }
    end

    puts "Loading postal codes from sheet: #{args[:sheet_name]}"

    parsed_sheet = xlsx.sheet(args[:sheet_name]).parse(columns).map do |row|
      state_id = states[row[:state_name].downcase][:id]
      city = Country::State::City.find_or_create_by(name: row[:city], state_id:)

      {
        postal_code: row[:postal_code],
        state_id:,
        city_id: city.id,
        neighborhood: row[:neighborhood]
      }
    end

    MxPostalCode.upsert_all(parsed_sheet.uniq, unique_by: %i[postal_code neighborhood])

    puts 'MX postal codes loaded successfully!'
  end
end
