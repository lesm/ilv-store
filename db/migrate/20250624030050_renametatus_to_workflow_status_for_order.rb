# frozen_string_literal: true

class RenametatusToWorkflowStatusForOrder < ActiveRecord::Migration[8.0]
  def change
    change_table :orders, bulk: true do |t|
      t.rename :status, :workflow_status
    end
  end
end
