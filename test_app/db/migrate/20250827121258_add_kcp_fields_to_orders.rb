class AddKcpFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :kcp_transaction_no, :string
    add_column :orders, :kcp_receipt_url, :text
  end
end
