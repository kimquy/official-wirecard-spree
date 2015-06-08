class Spree::PaymentMethod::WirecardCheckoutPageInstantbank < Spree::PaymentMethod::WirecardCheckoutPage
  self.paymenttype = 'INSTANTBANK'
end
