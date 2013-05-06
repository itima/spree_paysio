class AddStatusAndCodeToSpreePaysioPayment < ActiveRecord::Migration
  def up
    add_column :spree_paysio_payments, :status, :string
    add_column :spree_paysio_payments, :status_code, :string
    change_column :spree_paysio_payments, :order_id, :string
  end

  def down
    remove_column :spree_paysio_payments, :status
    remove_column :spree_paysio_payments, :status_code
    change_column :spree_paysio_payments, :order_id, :string
  end
end
