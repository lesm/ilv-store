# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :states, dependent: :destroy
  has_many :users, dependent: :restrict_with_error
  has_many :addresses, dependent: :restrict_with_error

  validates :name, :code, presence: true
  validates :name, :code, uniqueness: true

  MX_STATES = [
    { name: 'Aguascalientes', code: 'AGU' },
    { name: 'Baja California', code: 'BCN' },
    { name: 'Baja California Sur', code: 'BCS' },
    { name: 'Campeche', code: 'CAM' },
    { name: 'Coahuila de Zaragoza', code: 'COA' },
    { name: 'Colima', code: 'COL' },
    { name: 'Chiapas', code: 'CHP' },
    { name: 'Chihuahua', code: 'CHH' },
    { name: 'Ciudad de México', code: 'CMX' },
    { name: 'Durango', code: 'DUR' },
    { name: 'Guanajuato', code: 'GTO' },
    { name: 'Guerrero', code: 'GRO' },
    { name: 'Hidalgo', code: 'HID' },
    { name: 'Jalisco', code: 'JAL' },
    { name: 'México', code: 'MEX' },
    { name: 'Michoacán de Ocampo', code: 'MIC' },
    { name: 'Morelos', code: 'MOR' },
    { name: 'Nayarit', code: 'NAY' },
    { name: 'Nuevo León', code: 'NLE' },
    { name: 'Oaxaca', code: 'OAX' },
    { name: 'Puebla', code: 'PUE' },
    { name: 'Querétaro', code: 'QUE' },
    { name: 'Quintana Roo', code: 'ROO' },
    { name: 'San Luis Potosí', code: 'SLP' },
    { name: 'Sinaloa', code: 'SIN' },
    { name: 'Sonora', code: 'SON' },
    { name: 'Tabasco', code: 'TAB' },
    { name: 'Tamaulipas', code: 'TAM' },
    { name: 'Tlaxcala', code: 'TLA' },
    { name: 'Veracruz de Ignacio de la Llave', code: 'VER' },
    { name: 'Yucatán', code: 'YUC' },
    { name: 'Zacatecas', code: 'ZAC' }
  ].freeze
end
