class Spree::PaymentMethod::WirecardCheckoutPageSofort < Spree::PaymentMethod::WirecardCheckoutPage
  self.paymenttype = 'SOFORTUEBERWEISUNG'
end

