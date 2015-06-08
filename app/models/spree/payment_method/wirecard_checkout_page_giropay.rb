class Spree::PaymentMethod::WirecardCheckoutPageGiropay < Spree::PaymentMethod::WirecardCheckoutPage
  self.paymenttype = 'GIROPAY'
end

