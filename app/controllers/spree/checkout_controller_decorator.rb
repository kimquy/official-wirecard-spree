=begin
 * Shop System Plugins - Terms of use
 *
 * This terms of use regulates warranty and liability between Wirecard Central Eastern Europe (subsequently referred to as WDCEE) and it's
 * contractual partners (subsequently referred to as customer or customers) which are related to the use of plugins provided by WDCEE.
 *
 * The Plugin is provided by WDCEE free of charge for it's customers and must be used for the purpose of WDCEE's payment platform
 * integration only. It explicitly is not part of the general contract between WDCEE and it's customer. The plugin has successfully been tested
 * under specific circumstances which are defined as the shopsystem's standard configuration (vendor's delivery state). The Customer is
 * responsible for testing the plugin's functionality before putting it into production enviroment.
 * The customer uses the plugin at own risk. WDCEE does not guarantee it's full functionality neither does WDCEE assume liability for any
 * disadvantage related to the use of this plugin. By installing the plugin into the shopsystem the customer agrees to the terms of use.
 * Please do not use this plugin if you do not agree to the terms of use!
=end

module Spree
  CheckoutController.class_eval do
    before_filter :start_payment, :only => [:update]

    def start_payment

      return unless (params[:state] == "payment")

      logstr = ''
      params.each { |key, value|
        logstr += "#{key}:#{value}\n"
      }
      Spree::Wirecard::Logger.info "START_PAYMENT\n#{logstr}"


      birthday = nil
      payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])

      if payment_method.kind_of?(Spree::PaymentMethod::WirecardCheckoutPageInvoice)
        if params.has_key?(:wirecard_checkout_page)
          extra_params = params[:wirecard_checkout_page]
          if extra_params.has_key?(:birthday_year_invoice) and extra_params.has_key?(:birthday_month_invoice) and extra_params.has_key?(:birthday_day_invoice)
            birthday = Date.new(extra_params[:birthday_year_invoice].to_f, extra_params[:birthday_month_invoice].to_f, extra_params[:birthday_day_invoice].to_f)
            birthday = nil if birthday == Date.today
          end
        end
      end

      if payment_method.kind_of?(Spree::PaymentMethod::WirecardCheckoutPageInstallment)
        if params.has_key?(:wirecard_checkout_page)
          extra_params = params[:wirecard_checkout_page]
          if extra_params.has_key?(:birthday_year_installment) and extra_params.has_key?(:birthday_month_installment) and extra_params.has_key?(:birthday_day_installment)
            birthday = Date.new(extra_params[:birthday_year_installment].to_f, extra_params[:birthday_month_installment].to_f, extra_params[:birthday_day_installment].to_f)
            birthday = nil if birthday == Date.today
          end
        end
      end

      load_order

      Wirecard::Logger.debug @order.to_yaml
      Wirecard::Logger.debug @order.user.to_yaml

      return unless params[:order][:payments_attributes]

      return unless payment_method.kind_of?(Spree::PaymentMethod::WirecardCheckoutPage)

      payment = @order.payments.create!({:amount => @order.total,
                                         :payment_method => payment_method
                                        })
      payment.started_processing!
      payment.pend!

      update_params = object_params.dup
      update_params.delete(:payments_attributes)
      if @order.update_attributes(update_params)
        fire_event('spree.checkout.update')
        #  render :edit and return unless apply_coupon_code
      end

      if not @order.errors.empty?
        render :edit and return
      end

      protoused = request.protocol =~ /^https/ ? 'https' : 'http'

      urls = {}
      urls[:successURL] = wirecard_checkout_page_return_url(:protocol => protoused)
      urls[:cancelURL] = wirecard_checkout_page_return_url(:protocol => protoused)
      urls[:pendingURL] = wirecard_checkout_page_return_url(:protocol => protoused)
      urls[:failureURL] = wirecard_checkout_page_return_url(:protocol => protoused)
      urls[:confirmURL] = wirecard_checkout_page_confirm_url(:protocol => 'https')

      extra_params = {}
      extra_params[:birthday] = birthday unless birthday.nil?

      begin
        redirect_url = payment_method.init_payment(@order, urls, extra_params, request)
        if payment_method.preferred_use_iframe
          render :file => 'spree/checkout/wirecardcheckoutpageiframe', :locals => { :redirect_url => redirect_url, :payment_method => payment_method }
        else
          redirect_to redirect_url
        end

      rescue Exception => e
        flash.notice = e.message
      end

      return
    end

  end
end
