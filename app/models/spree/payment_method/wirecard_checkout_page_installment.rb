class Spree::PaymentMethod::WirecardCheckoutPageInstallment < Spree::PaymentMethod::WirecardCheckoutPage

  preference :min_amount, :decimal
  preference :max_amount, :decimal

  #attr_accessible :preferred_min_amount, :preferred_max_amount
  self.paymenttype = 'INSTALLMENT'

  class_attribute :min_age
  self.min_age = 18

  # selecting a different template
  def method_type
    'wirecardcheckoutpageinstallment'
  end

  def add_additional_params?
    true
  end

  def visible(display_on, order)
    if display_on == :front_end
      return false unless order.currency == 'EUR'

      %w(firstname lastname address1 address2 city country zipcode state state_name).each { |f|
        return false unless order.bill_address.send(f) == order.ship_address.send(f)
      }

      return false unless preferred_min_amount > 0
      return false unless preferred_max_amount > 0

      return false if order.total < preferred_min_amount
      return false unless order.total < preferred_max_amount
    end

    true
  end

  def allowed?(order, urls, extra_params, request)
    raise t('wirecard_checkout_page.birthday_required') if extra_params[:birthday].nil?
    raise t('wirecard_checkout_page.installment_notallowed') unless visible(:front_end, order)
    raise t('wirecard_checkout_page.installment_min_age') if calculate_age(extra_params[:birthday]) < self.min_age
  end

  # http://stackoverflow.com/a/2068206
  def calculate_age(start_date, end_date = Date.today)
    end_date.year - start_date.year - ((end_date.month > start_date.month || (end_date.month == start_date.month && end_date.day >= start_date.day)) ? 0 : 1)
  end

end
