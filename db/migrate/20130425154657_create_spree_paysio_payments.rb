class CreateSpreePaysioPayments < ActiveRecord::Migration
  def change
    create_table :spree_paysio_payments do |t|
      t.string :object
      t.string :charge_id
      t.string :merchant_id
      t.string :payment_system_id
      t.integer :order_id

      t.timestamps
    end
  end
end
