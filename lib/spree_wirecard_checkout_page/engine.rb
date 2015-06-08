module SpreeWirecardCheckoutPage
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_wirecard_checkout_page'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    initializer "spree_wirecard_checkout_page.register.payment_methods" do |app|
      app.config.spree.payment_methods += [
          Spree::PaymentMethod::WirecardCheckoutPage,
          Spree::PaymentMethod::WirecardCheckoutPageBmc,
          Spree::PaymentMethod::WirecardCheckoutPageC2p,
          Spree::PaymentMethod::WirecardCheckoutPageCcard,
          Spree::PaymentMethod::WirecardCheckoutPageCcardmoto,
          Spree::PaymentMethod::WirecardCheckoutPageEkonto,
          Spree::PaymentMethod::WirecardCheckoutPageElv,
          Spree::PaymentMethod::WirecardCheckoutPageEps,
          Spree::PaymentMethod::WirecardCheckoutPageGiropay,
          Spree::PaymentMethod::WirecardCheckoutPageIdl,
          Spree::PaymentMethod::WirecardCheckoutPageInstallment,
          Spree::PaymentMethod::WirecardCheckoutPageInstantbank,
          Spree::PaymentMethod::WirecardCheckoutPageInvoice,
          Spree::PaymentMethod::WirecardCheckoutPageMaestro,
          Spree::PaymentMethod::WirecardCheckoutPageMoneta,
          Spree::PaymentMethod::WirecardCheckoutPageMpass,
          Spree::PaymentMethod::WirecardCheckoutPageP24,
          Spree::PaymentMethod::WirecardCheckoutPagePaypal,
          Spree::PaymentMethod::WirecardCheckoutPagePbx,
          Spree::PaymentMethod::WirecardCheckoutPagePoli,
          Spree::PaymentMethod::WirecardCheckoutPagePsc,
          Spree::PaymentMethod::WirecardCheckoutPageQuick,
          Spree::PaymentMethod::WirecardCheckoutPageSkrilldirect,
          Spree::PaymentMethod::WirecardCheckoutPageSkrillwallet,
          Spree::PaymentMethod::WirecardCheckoutPageSofort
      ]
    end

    config.to_prepare &method(:activate).to_proc
  end
end
