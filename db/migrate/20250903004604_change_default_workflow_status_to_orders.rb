# frozen_string_literal: true

class ChangeDefaultWorkflowStatusToOrders < ActiveRecord::Migration[8.0]
  def up
    change_column_default :orders, :workflow_status, from: 'created', to: 'pending'

    execute <<-SQL.squish
      UPDATE orders
      SET workflow_status = 'pending'
      WHERE workflow_status = 'created';
    SQL
  end

  def down
    change_column_default :orders, :workflow_status, from: 'pending', to: 'created'

    execute <<-SQL.squish
      UPDATE orders
      SET workflow_status = 'created'
      WHERE workflow_status = 'pending';
    SQL
  end
end
