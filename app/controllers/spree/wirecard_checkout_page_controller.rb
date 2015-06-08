require 'cgi'

module Spree
  class WirecardCheckoutPageController < StoreController
    # disable CSRF, posts do not contain X-CSRF-Token Header
    protect_from_forgery :except => [:confirm, :return]

    def confirm
      logstr = ''
      params.each { |key, value|
        logstr += "#{key} #{value}\n"
      }
      Spree::Wirecard::Logger.info "CONFIRM\n#{logstr}"

      @order = Order.find_by_id(params[:spree_order_id])

      payment = @order.payments.where(:state => "pending",
                                      :payment_method_id => payment_method).first

      transaction = Spree::WirecardCheckoutPage.create_from_postback(params)

      payment.source = transaction
      payment.avs_response = params[:avsResponseCode]
      payment.save

      begin
        payment_method.verify_response(params)
      rescue Exception => e
        payment.failure!
        @order.update
        render :text => '<QPAY-CONFIRMATION-RESPONSE result="' + CGI.escapeHTML(e.message) + '"/>'
        return
      end

      case params[:paymentState]
        when 'SUCCESS'
          payment.complete!
          @order.state = :complete
          @order.finalize!
        when 'PENDING'
          #default state is pending, do not update paymentstate
          @order.finalize!
        when 'CANCEL'
        else
          payment.failure!
      end

      @order.update!

      render :text => '<QPAY-CONFIRMATION-RESPONSE result="OK"/>'
    end


    def return

      if params[:xIframeUsed]
        render :layout => false, :file => 'spree/checkout/wirecardcheckoutpageiframebreakout'
        return
      end

      logstr = ''
      params.each { |key, value|
        logstr += "#{key} #{value}\n"
      }
      Spree::Wirecard::Logger.info "RETURN\n#{logstr}"

      @order = Order.find_by_id(params[:spree_order_id])

      #begin
        #payment_method.verify_response(params) #verify_response is not working because of iframe breakout. never the less, we check response within confirmUrl
      #rescue Exception => e
        #flash.notice = e.message
        #redirect_to checkout_state_path(@order.state)
        #return
      #end

      case params[:paymentState]
        when 'SUCCESS'
          flash.notice = t('wirecard_checkout_page.order_processed_successfully')
          redirect_to spree.order_path(@order)
        when 'PENDING'
          flash.notice = t('wirecard_checkout_page.order_processed_successfully_payment_pending')
          redirect_to spree.order_path(@order)
        when 'CANCEL'
          flash.notice = t('wirecard_checkout_page.payment_has_cancelled')
          redirect_to checkout_state_path(@order.state)
        else
          #payment.failure!
          flash.notice = params[:consumerMessage]
          redirect_to checkout_state_path(@order.state)
      end

    end


    def payment_method
      Spree::PaymentMethod.find(params[:spree_payment_method_id])
    end
  end
end
