namespace :ibge do
  task sync_cities: :environment do
    require 'csv'
    csv_text = File.read(File.join(__dir__, 'RELATORIO_DTB_BRASIL_MUNICIPIO_2020_v2.csv'))
    csv = CSV.parse(csv_text, headers: true, col_sep: ';')

    states_acronyms = {
      'Acre' => 'AC',
      'Alagoas' => 'AL',
      'Amapá' => 'AP',
      'Amazonas' => 'AM',
      'Bahia' => 'BA',
      'Ceará' => 'CE',
      'Distrito Federal' => 'DF',
      'Espírito Santo' => 'ES',
      'Goiás' => 'GO',
      'Maranhão' => 'MA',
      'Mato Grosso' => 'MT',
      'Mato Grosso do Sul' => 'MS',
      'Minas Gerais' => 'MG',
      'Pará' => 'PA',
      'Paraíba' => 'PB',
      'Paraná' => 'PR',
      'Pernambuco' => 'PE',
      'Piauí' => 'PI',
      'Rio de Janeiro' => 'RJ',
      'Rio Grande do Norte' => 'RN',
      'Rio Grande do Sul' => 'RS',
      'Rondônia' => 'RO',
      'Roraima' => 'RR',
      'Santa Catarina' => 'SC',
      'São Paulo' => 'SP',
      'Sergipe' => 'SE',
      'Tocantins' => 'TO'
    }

    csv.each do |row|
      state_code = row['UF']
      state_name = row['Nome_UF']
      state_acronym = states_acronyms[state_name]
      city_code = row['Código_Município_Completo']
      city_name = row['Nome_Município']

      state = Ibge::State.create_with(acronym: state_acronym)
                         .find_or_initialize_by(code: state_code)
      state.name = state_name

      Vtex::Sync::Logger.log_what_will_be_synced(state)
      state.save! if state.changed?

      city = Ibge::City.create_with(state: state)
                       .find_or_initialize_by(code: city_code)
      city.name = city_name

      Vtex::Sync::Logger.log_what_will_be_synced(city)
      city.save! if city.changed?
    end
  end

  task sync_districts: :environment do
    require 'csv'
    csv_text = File.read(File.join(__dir__, 'RELATORIO_DTB_BRASIL_DISTRITO_2020_v2.csv'))
    csv = CSV.parse(csv_text, headers: true, col_sep: ';')

    csv.each do |row|
      city_code = row['Código_Município_Completo']
      district_code = row['Código_de_Distrito_Completo']
      district_name = row['Nome_Distrito']

      city = Ibge::City.find_by! code: city_code

      district = Ibge::District.create_with(city: city)
                               .find_or_initialize_by(code: district_code)
      district.name = district_name

      Vtex::Sync::Logger.log_what_will_be_synced(district)
      district.save! if district.changed?
    end
  end
end
