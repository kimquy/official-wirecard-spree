class Spree::PaymentMethod::WirecardCheckoutPageEkonto < Spree::PaymentMethod::WirecardCheckoutPage
  self.paymenttype = 'EKONTO'
end
