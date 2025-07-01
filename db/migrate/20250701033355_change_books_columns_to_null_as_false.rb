# frozen_string_literal: true

class ChangeBooksColumnsToNullAsFalse < ActiveRecord::Migration[8.0]
  def change
    change_table :books, bulk: true do |t|
      t.change_null :cover_color, false
      t.change_null :dimensions, false
      t.change_null :weight_grams, false
    end
  end
end
