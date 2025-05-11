# frozen_string_literal: true

namespace :mx_postal_codes do
  desc 'Load MX postal codes from xlsx file'

  task load: :environment do
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

    xlsx.sheets.drop(1).each do |sheet_name|
      puts "Loading postal codes from sheet: #{sheet_name}"

      parsed_sheet = xlsx.sheet(sheet_name).parse(columns).map do |row|
        state_id = states[row[:state_name].downcase][:id]
        city = Country::State::City.find_or_create_by(name: row[:city], state_id:)

        {
          postal_code: row[:postal_code],
          state_id:,
          city_id: city.id,
          neighborhood: row[:neighborhood]
        }
      end

      parsed_sheet.uniq.in_groups_of(100, false) do |group|
        MxPostalCode.upsert_all(group, unique_by: %i[postal_code neighborhood])
      end
    end

    puts 'MX postal codes loaded successfully!'

    FileUtils.rm_rf(unzip_file_path)
  end
end
