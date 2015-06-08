class Spree::PaymentMethod::WirecardCheckoutPageQuick < Spree::PaymentMethod::WirecardCheckoutPage
  self.paymenttype = 'QUICK'
end
