module Spree
  Order.class_eval do


    def available_payment_methods
      @available_payment_methods ||= Spree::PaymentMethod::WirecardCheckoutPage.available(:front_end, self)
    end

  end
end
