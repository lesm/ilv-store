# frozen_string_literal: true

class RemoveRedundantIndexProductTranslationsOnProductIdIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :product_translations, :product_id
  end
end
