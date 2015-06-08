require 'net/http'

class Spree::PaymentMethod::WirecardCheckoutPage < Spree::PaymentMethod
  preference :customer_id, :string, :default => 'D200001'
  preference :secret, :string, :default => 'B8AKTPWBRMNBV455FG6M2DANE99WU2'
  preference :shop_id, :string
  preference :service_url, :string
  preference :image_url, :string
  preference :max_retries, :integer, :default => -1
  preference :auto_deposit, :boolean, :default => true
  preference :send_additional_data, :boolean, :default => false
  preference :use_iframe, :boolean, :default => false
  preference :display_text, :string

  #attr_accessible :preferred_customer_id, :preferred_secret, :preferred_shop_id #, :preferred_server, :preferred_test_mode
  #attr_accessible :preferred_service_url, :preferred_image_url
  #attr_accessible :preferred_max_retries, :preferred_auto_deposit, :preferred_send_additional_data
  #attr_accessible :preferred_use_iframe, :preferred_display_text

  class_attribute :paymenttype, :init_url, :plugin_version, :plugin_name, :window_name
  self.paymenttype = 'SELECT'
  self.init_url = 'https://checkout.wirecard.com/page/init-server.php'
  self.plugin_name = 'spree2_wirecardcheckoutpage'
  self.plugin_version = '1.1.0'
  self.window_name = 'wirecardCheckoutPageIframe'

  def method_type
    'wirecardcheckoutpage'
  end

  def source_required?
    true
  end

  def payment_source_class
    Spree::WirecardCheckoutPage
  end

  # important! never set to true, otherwise another confirm page is shown, after the payment
  def payment_profiles_supported?
    false
  end

  def auto_capture?
    true
  end

  def self.available(display_on = 'both', order)
    methods = Spree::PaymentMethod.available(display_on)

    methods.delete_if { |p|
      if p.kind_of?(Spree::PaymentMethod::WirecardCheckoutPage)
        !p.visible(display_on, order)
      else
        false
      end
    }

  end

  def visible(display_on, order)
    true
  end

  def allowed?(order, urls, extra_params, request)
    true
  end

  def init_payment(order, urls, extra_params, request)
    allowed?(order, urls, extra_params, request)

    params = {}
    params[:customerId] = preferred_customer_id
    if preferred_shop_id != ""
      params[:shopId] = preferred_shop_id
    end
    if preferred_image_url != ""
      params[:imageUrl] = preferred_image_url
    end
    params[:amount] = order.total.to_s
    params[:paymentType] = self.paymenttype
    params[:currency] = order.currency
    params[:language] = I18n.locale
    params[:orderDescription] = "#{order.number}"
    if preferred_display_text != ""
      params[:displayText] = preferred_display_text
    end
    if preferred_auto_deposit == true
      params[:autoDeposit] = preferred_auto_deposit
    end
    params[:consumerIpAddress] = request.env['HTTP_X_REAL_IP'] || request.env['REMOTE_ADDR']
    params[:consumerUserAgent] = request.env['HTTP_USER_AGENT']
    if preferred_service_url != ""
      params[:serviceURL] = preferred_service_url
    end
    if preferred_max_retries != -1
      params[:maxRetries] = preferred_max_retries
    end
    params[:windowName] = self::window_name

    urls.each { |key, value|
      params[key] = value
    }

    if extra_params.has_key?(:birthday)
      params[:consumerBirthdate] = extra_params[:birthday].to_s
    end

    params[:pluginVersion] = Base64.encode64(Spree::Config[:site_name] + ';' + Spree::version + ';;' + self::plugin_name + ';' + self::plugin_version)

    params[:spree_payment_method_id] = self.id
    params[:spree_order_id] = order.id

    if add_additional_params?
      set_additional_params(params, order)
    end

    fingerprint_order = Array.new
    fingerprint_order.append('secret')
    fingerprint_values = preferred_secret
    params.each { |key, value|
      fingerprint_order.append key
      fingerprint_values += value.to_s
    }

    fingerprint_order.append :requestFingerprintOrder
    fingerprint_values += fingerprint_order.join(',')

    params[:requestFingerprintOrder] = fingerprint_order.join(',')
    params[:requestFingerprint] = Digest::MD5.hexdigest(fingerprint_values)

    if preferred_use_iframe
      params[:xIframeUsed] = true
    end

    logstr = ''
    params.each { |key, value|
      logstr += "#{key} #{value}\n"
    }
    Spree::Wirecard::Logger.info "REQUEST\n#{logstr}"

    uri = URI(self.init_url)
    puts uri.path
    http_request = Net::HTTP::Post.new(uri.path)
    http_request.form_data = params

    connection = Net::HTTP.new(uri.host, uri.port)
    connection.use_ssl = true
    connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = connection.start { |http|
      http_response = http.request(http_request)
      Spree::Wirecard::Logger.debug http_response.body
      params = Rack::Utils.parse_query http_response.body

      if params.has_key?('redirectUrl')
        return params['redirectUrl']
      end

      if params.has_key?('message')
        raise params['message']
      end

    }

    raise I18n::t('wirecard_checkout_page.init_failed')
  end

  def add_additional_params?
    return preferred_send_additional_data
  end

  def set_additional_params(params, order)
    #Spree::Wirecard::Logger.debug order.bill_address.to_yaml
    #Spree::Wirecard::Logger.debug order.ship_address.to_yaml
    #Spree::Wirecard::Logger.debug order.bill_address.state.to_yaml
    params[:consumerEmail] = order.email

    params[:consumerBillingFirstname] = order.bill_address.firstname
    params[:consumerBillingLastname] = order.bill_address.lastname
    params[:consumerBillingAddress1] = order.bill_address.address1
    params[:consumerBillingAddress2] = order.bill_address.address2
    params[:consumerBillingCity] = order.bill_address.city
    params[:consumerBillingCountry] = order.bill_address.country.iso
    params[:consumerBillingZipCode] = order.bill_address.zipcode
    params[:consumerBillingPhone] = order.bill_address.phone
    params[:consumerBillingState] = order.bill_address.state ? order.bill_address.state : order.bill_address.state_name

    if order.bill_address.country.iso == 'US' or order.bill_address.country.iso == 'CA'
      params[:consumerBillingState] = order.bill_address.state.abbr
    end

    params[:consumerShippingFirstname] = order.ship_address.firstname
    params[:consumerShippingLastname] = order.ship_address.lastname
    params[:consumerShippingAddress1] = order.ship_address.address1
    params[:consumerShippingAddress2] = order.ship_address.address2
    params[:consumerShippingCity] = order.ship_address.city
    params[:consumerShippingCountry] = order.ship_address.country.iso
    params[:consumerShippingZipCode] = order.ship_address.zipcode
    params[:consumerShippingPhone] = order.ship_address.phone
    params[:consumerShippingState] = order.ship_address.state ? order.ship_address.state : order.ship_address.state_name

    if order.bill_address.country.iso == 'US' or order.ship_address.country.iso == 'CA'
      params[:consumerShippingState] = order.ship_address.state.abbr
    end

  end

  def verify_response(params)

    raise "paymentState is missing" unless params.has_key?(:paymentState)

    if params[:paymentState] == 'SUCCESS' || params[:paymentState] == 'PENDING'
      raise "responseFingerprint is missing" unless params.has_key?(:responseFingerprint)
      raise "responseFingerprintOrder is missing" unless params.has_key?(:responseFingerprintOrder)
    end

    if params[:paymentState] == 'SUCCESS' || params[:paymentState] == 'PENDING'
      fields = params[:responseFingerprintOrder].split(",")
      values = ''
      fields.each { | f |
        values += f == 'secret' ? preferred_secret : params[f]
      }

      Rails.logger.debug "Fingerprint his: " + params[:responseFingerprint] + " mine: " + Digest::MD5.hexdigest(values)

      if Digest::MD5.hexdigest(values) != params[:responseFingerprint]
        raise "responseFingerprint verification failed"
      end
    end

    true
  end

end
