class Spree::PaymentMethod::WirecardCheckoutPagePaypal < Spree::PaymentMethod::WirecardCheckoutPage
  self.paymenttype = 'PAYPAL'
end

