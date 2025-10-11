# frozen_string_literal: true

class Product
  module TypesenseConfig
    extend ActiveSupport::Concern

    class_methods do
      def typesense_schema # rubocop:disable Metrics/MethodLength
        {
          name: typesense_collection_name,
          fields: [
            { name: 'id', type: 'string' },
            { name: 'title_es', type: 'string' },
            { name: 'title_en', type: 'string' },
            { name: 'subtitle_es', type: 'string', optional: true },
            { name: 'subtitle_en', type: 'string', optional: true },
            { name: 'price', type: 'float' },
            { name: 'stock', type: 'int32' },
            { name: 'created_at', type: 'int64' }
          ],
          default_sorting_field: 'created_at'
        }
      end

      def typesense_query_by
        "title_#{I18n.locale},subtitle_#{I18n.locale}"
      end
    end

    def typesense_document
      {
        id: id.to_s,
        **attributes_es,
        **attributes_en,
        price: current_translation.price.to_f,
        stock: stock,
        created_at: created_at.to_i
      }
    end

    private

    def attributes_es
      t = translations.find { |t| t.locale == 'es' }

      { title_es: t.title, subtitle_es: t.subtitle }
    end

    def attributes_en
      t = translations.find { |t| t.locale == 'en' }

      { title_en: t.title, subtitle_en: t.subtitle }
    end
  end
end
