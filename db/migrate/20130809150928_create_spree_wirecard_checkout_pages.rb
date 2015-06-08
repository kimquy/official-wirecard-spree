class CreateSpreeWirecardCheckoutPages < ActiveRecord::Migration
  def change
    create_table :spree_wirecard_checkout_pages do |t|
      t.string :payment_type, :payment_state, :order_number, :gateway_reference_number
      t.text :data
      t.timestamps
    end
  end
end
