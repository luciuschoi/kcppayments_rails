class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :order_no
      t.string :product_name
      t.integer :amount
      t.string :buyer_name
      t.string :buyer_email
      t.string :status
      t.string :payment_method
      t.integer :tax_free_amount

      t.timestamps
    end
  end
end
