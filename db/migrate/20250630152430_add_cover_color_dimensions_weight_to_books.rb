# frozen_string_literal: true

class AddCoverColorDimensionsWeightToBooks < ActiveRecord::Migration[8.0]
  def change
    change_table :books, bulk: true do |t|
      t.string :cover_color
      t.string :dimensions
      t.integer :weight_grams
    end
  end
end
