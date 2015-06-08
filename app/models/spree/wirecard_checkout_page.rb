class Spree::WirecardCheckoutPage < ActiveRecord::Base
  has_many :payments, :as => :source

  #attr_accessible :payment_type, :payment_state, :order_number, :gateway_reference_number, :data

  def self.create_from_postback(params)

   excl = %w(paymentState paymentType orderNumber gatewayReferenceNumber responseFingerprintOrder responseFingerprint controller action xIframeUsed spree_payment_method_id spree_order_id)
 
    dat = {}
    params.each { |k, v|
      next if excl.include? k
      dat[k] = v
    }
    
    Spree::WirecardCheckoutPage.create(:payment_type => params[:paymentType],
                                       :payment_state => params[:paymentState],
                                       :order_number => params[:orderNumber],
                                       :gateway_reference_number => params[:gatewayReferenceNumber],
                                       :data => dat)
  end

  def data
    YAML.load(self[:data])
  end

  def data=(value)
    self[:data] = value.to_yaml
  end

end
