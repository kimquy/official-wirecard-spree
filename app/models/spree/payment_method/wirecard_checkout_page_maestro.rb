class Spree::PaymentMethod::WirecardCheckoutPageMaestro < Spree::PaymentMethod::WirecardCheckoutPage
  self.paymenttype = 'MAESTRO'
end
