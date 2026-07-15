# frozen_string_literal: true

class RenameDefaultToIsDefaultOnAddresses < ActiveRecord::Migration[8.1]
  def change
    rename_column :addresses, :default, :is_default
  end
end
