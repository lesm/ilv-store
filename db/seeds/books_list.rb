# frozen_string_literal: true

books = [
  {
    language: 'Chatino', language_zone: 'Alta occidental', edition_number: '1', pages_number: '980',
    internal_code: 'ILVctp92-027BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 337,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento en chatino de la zona alta occidental',
          subtitle: "Cha' Su'we nu nchkwi' cha' 'in Jesucristo nu nka x'naan", price: 100, cover_color: 'blue'
        },
        {
          locale: 'en', title: 'The New Testament in Chatino of the western high zone',
          subtitle: "Cha' Su'we nu nchkwi' cha' 'in Jesucristo nu nka x'naan", price: 5
        }
      ]
    }
  },
  {
    language: 'Chatino', language_zone: 'Alta occidental', edition_number: '1', pages_number: '473',
    internal_code: 'ILVctpXX-000LG', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 224,
      translations_attributes: [
        {
          locale: 'es', title: 'Diccionario chatino de la zona alta [VIMSA 47]',
          subtitle: 'Diccionario chatino de la zona alta; Panixtlahuaca, Oaxaca y otros pueblos', price: 560
        },
        {
          locale: 'en', title: 'Chatino dictionary of the high zone [Vimsa 47]',
          subtitle: 'Chatino dictionary of the high zone; Panixtlahuaca, Oaxaca and other villages', price: 28
        }
      ]
    }
  },
  {
    language: 'Chinanteco', language_zone: 'Lalana', edition_number: '3', pages_number: '744',
    internal_code: 'ILVcnl11-144BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 4453,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento',
          subtitle: 'Júu² ˈmɨɨn³² ˈe³ ca²³ŋɨ́n² Dios', price: 100
        },
        {
          locale: 'en', title: 'The New Testament',
          subtitle: 'Júu² ˈmɨɨn³² ˈe³ ca²³ŋɨ́n² Dios', price: 10
        }
      ]
    }
  },
  {
    language: 'Chinanteco', language_zone: 'Lealao', edition_number: '2', pages_number: '955',
    internal_code: 'ILVcle07-064BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 90,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento y Salmos',
          subtitle: 'Ja̱³la³ fáh⁴dxá⁴² dxʊ⁴ hi³mɨɨ³² hi³ chiáh² Ñúh³a² Jesucristo chieeyhˈ', price: 100
        },
        {
          locale: 'en', title: 'The New Testament and Psalms',
          subtitle: 'Ja̱³la³ fáh⁴dxá⁴² dxʊ⁴ hi³mɨɨ³² hi³ chiáh² Ñúh³a² Jesucristo chieeyhˈ', price: 10
        }
      ]
    }
  },
  {
    language: 'Chinanteco', language_zone: 'Lealao', edition_number: '1', pages_number: '534',
    internal_code: 'ILVcle96-000LG', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 189,
      translations_attributes: [
        {
          locale: 'es', title: 'Diccionario chinanteco de Lealao [VIMSA 35]',
          subtitle: 'Diccionario chinanteco de San Juan Lealao, Oaxaca', price: 600
        },
        {
          locale: 'en', title: 'Dictionary Chininteco of Lealao [Vimsa 35]',
          subtitle: 'Minist Dictionary of St. John Lealao, Oxaca', price: 30
        }
      ]
    }
  },
  {
    language: 'Mazateco', language_zone: 'Eloxochitlán', edition_number: '1', pages_number: '717',
    internal_code: 'ILVmaa12-006BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 352,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento en el mazateco de Eloxochitlán',
          subtitle: "Én Xi̱tse̱-la̱ Nainá ra a̱'ta 'tse̱ Jesucristo", price: 100
        },
        {
          locale: 'en', title: 'The New Testament in Eloxochitlán Mazateco',
          subtitle: "Én Xi̱tse̱-la̱ Nainá ra a̱'ta 'tse̱ Jesucristo", price: 5
        }
      ]
    }
  },
  {
    language: 'Mixe', language_zone: 'Coatlán', edition_number: '1', pages_number: '959',
    internal_code: 'ILVmco75-090BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 55,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento',
          subtitle: 'El Nuevo Testamento', price: 100
        },
        {
          locale: 'en', title: 'The New Testament',
          subtitle: 'The New Testament', price: 5
        }
      ]
    }
  },
  {
    language: 'Mixe', language_zone: 'Coatlán', edition_number: '1', pages_number: '459',
    internal_code: 'ILVmco97-000LG', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 19,
      translations_attributes: [
        {
          locale: 'es', title: 'Diccionario mixe de Coatlan, Oaxaca [VIMSA 32]',
          subtitle: 'Diccionario mixe de Coatlán, Oaxaca', price: 600
        },
        {
          locale: 'en', title: 'Mixe Dictionary of Coatlan, Oaxaca [Vimsa 32]',
          subtitle: 'Mixe Dictionary of Coatlan, Oaxaca [Vimsa 32]', price: 30
        }
      ]
    }
  },
  {
    language: 'Mixe', language_zone: 'Totontepec', edition_number: '1', pages_number: '944',
    internal_code: 'ILVmto89-019BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 5,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento',
          subtitle: 'Je̱ Nam Ko̱jtstán', price: 100
        },
        {
          locale: 'en', title: 'The New Testament',
          subtitle: 'Je̱ Nam Ko̱jtstán', price: 5
        }
      ]
    }
  },
  {
    language: 'Mixe', language_zone: 'Totontepec', edition_number: '1', pages_number: '353',
    internal_code: 'ILVmto64-086LG', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 4,
      translations_attributes: [
        {
          locale: 'es', title: 'Vocabulario mixe de Totontepec [VIMSA 14]',
          subtitle: 'Vocabulario mixe de Totontepec', price: 180
        },
        {
          locale: 'en', title: 'Totontepec Mixe Vocabulary [Vimsa 14]',
          subtitle: 'Totontepec Mixe Vocabulary', price: 9
        }
      ]
    }
  },
  {
    language: 'Mixteco', language_zone: 'Santa María Zacatepec', edition_number: '1', pages_number: '835',
    internal_code: 'ILVmza13-066BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 308,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento',
          subtitle: 'Tutu Ndioo ña kàꞌan chaꞌaꞌ Rachaꞌnu Jesucristu', price: 100
        },
        {
          locale: 'en', title: 'The New Testament',
          subtitle: 'Tutu Ndioo ña kàꞌan chaꞌaꞌ Rachaꞌnu Jesucristu', price: 5
        }
      ]
    }
  },
  {
    language: 'Mixteco', language_zone: 'Santa María Zacatepec', edition_number: '1', pages_number: '140',
    internal_code: 'ILVmza11-000LG', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 18,
      translations_attributes: [
        {
          locale: 'es', title: 'Gramatica popular del Tacuate (Mixteco) de Santa Maria Zacatepec, Oaxaca',
          subtitle: 'Gramatica popular del Tacuate (Mixteco) de Santa Maria Zacatepec, Oaxaca', price: 140
        },
        {
          locale: 'en', title: 'Popular Tacuate (Mixteco) grammar of Santa Maria Zacatepec, Oaxaca',
          subtitle: 'Popular Tacuate (Mixteco) grammar of Santa Maria Zacatepec, Oaxaca', price: 7.5
        }
      ]
    }
  },
  {
    language: 'Náhuatl', language_zone: 'Norte de Oaxaca', edition_number: '1', pages_number: '534',
    internal_code: 'ILVnhy06-000BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 50,
      translations_attributes: [
        {
          locale: 'es', title: 'Nuevo Testamento',
          subtitle: 'Itlajtol Totajtzin Dios', price: 125
        },
        {
          locale: 'en', title: 'New Testament',
          subtitle: 'Itlajtol Totajtzin Dios', price: 6.25
        }
      ]
    }
  },
  {
    language: 'Zapoteco', language_zone: 'Chichicapan', edition_number: '1', pages_number: '1167',
    internal_code: 'ILVzpv89-005BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 58,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento',
          subtitle: "Xchi'dxyi cuubi Dxiohs nin Daada Jesucristu", price: 100
        },
        {
          locale: 'en', title: 'The New Testament',
          subtitle: "Xchi'dxyi cuubi Dxiohs nin Daada Jesucristu", price: 5
        }
      ]
    }
  },
  {
    language: 'Zapoteco', language_zone: 'Istmo', edition_number: '2', pages_number: '787',
    internal_code: 'ILVzai06-055BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 105,
      translations_attributes: [
        {
          locale: 'es', title: 'Nuevo Testamento en el zapoteco del Istmo',
          subtitle: 'Stiidxa Dios Didxazá', price: 100
        },
        {
          locale: 'en', title: 'New Testament in the Isthmus Zapotec',
          subtitle: 'Stiidxa Dios Didxazá', price: 5
        }
      ]
    }
  },
  {
    language: 'Zapoteco', language_zone: 'Mitla', edition_number: '2', pages_number: '595',
    internal_code: 'ILVzaw05-087BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 754,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento',
          subtitle: 'Stiidxa Dios Didxazá', price: 100
        },
        {
          locale: 'en', title: 'The New Testament',
          subtitle: 'Xtidxcoob Dios ni biädna Dad Jesucrist', price: 5
        }
      ]
    }
  },
  {
    language: 'Zapoteco', language_zone: 'Mitla', edition_number: '1', pages_number: '300',
    internal_code: 'ILVzaw91-046LG', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 192,
      translations_attributes: [
        {
          locale: 'es', title: 'Diccionario zapoteco de Mitla, Oaxaca [VIMSA 31]',
          subtitle: 'Diccionario zapoteco de Mitla, Oaxaca [VIMSA 31]', price: 50
        },
        {
          locale: 'en', title: 'Zapotec Dictionary of Mitla, Oaxaca [Vimsa 31]',
          subtitle: 'Zapotec Dictionary of Mitla, Oaxaca [Vimsa 31]', price: 2.5
        }
      ]
    }
  },
  {
    language: 'Zapoteco', language_zone: 'Texmelucan', edition_number: '2', pages_number: '1013',
    internal_code: 'ILVzpz04-049BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 427,
      translations_attributes: [
        {
          locale: 'es', title: 'Nuevo Testamento con Salmos y Proverbios',
          subtitle: 'De riidz ni trat cub nu bicy nu Ñgyoozh mbecy', price: 100
        }
      ]
    }
  },
  {
    language: 'Zapoteco', language_zone: 'Texmelucan', edition_number: '1', pages_number: '245',
    internal_code: 'ILVzpz95-116BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 128,
      translations_attributes: [
        {
          locale: 'es', title: 'Sumario de la historia de los israelitas',
          subtitle: 'Sumario de la historia de los israelitas', price: 60
        },
        {
          locale: 'en', title: 'Sumario de la historia de los israelitas',
          subtitle: 'Sumario de la historia de los israelitas', price: 3
        }
      ]
    }
  },
  {
    language: 'Zapoteco', language_zone: 'Sierra de Juárez', edition_number: '1', pages_number: '522',
    internal_code: 'ILVzaa2010BI', dimensions: '23 x 3 x 30', weight_grams: 900, cover_color: 'blue',
    product_attributes: {
      stock: 10,
      translations_attributes: [
        {
          locale: 'es', title: 'El Nuevo Testamento',
          subtitle: 'Ca Titsaˈ De Laˈlabani Para Iyate Ca Enneˈ', price: 100
        },
        {
          locale: 'en', title: 'The New Testament',
          subtitle: 'Ca Titsaˈ De Laˈlabani Para Iyate Ca Enneˈ', price: 5
        }
      ]
    }
  }
].freeze

books.each do |book_data|
  next if Book.exists?(internal_code: book_data[:internal_code])

  Book.create!(book_data)
end
