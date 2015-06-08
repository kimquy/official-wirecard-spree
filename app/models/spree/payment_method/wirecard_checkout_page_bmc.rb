class Spree::PaymentMethod::WirecardCheckoutPageBmc < Spree::PaymentMethod::WirecardCheckoutPage
  self.paymenttype = 'BANCONTACT_MISTERCASH'
end
