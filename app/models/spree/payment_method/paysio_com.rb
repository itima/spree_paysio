module Spree
  class PaymentMethod::PaysioCom < PaymentMethod
    
    attr_accessible :preferred_client_api_key, :preferred_client_publishable_key

    preference :client_api_key,     :string
    preference :client_publishable_key, :string

    def payment_source_class
      PaysioPayment
    end

    def payment_profiles_supported?
      false
    end
    
    def actions
      %w{capture void}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      payment.state != 'void'
    end

    def capture(*args)
      puts '*'*20
      puts args.inspect
      puts '*'*20
      # ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def void(*args)
      puts '*'*20
      puts args.inspect
      puts '*'*20
      # ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def authorize(money, paysio_payment, options = {})
      paysio_payment.order_id = options[:order_id]
      paysio_payment.save
      paysio_payment
    end

    class << self
      def current_method
        PaymentMethod.find_by_type(name)
      end

      def preferences
        prefs = {}
        if current_method.present?
          prefs.merge! current_method.preferences
        end
        prefs
      end
    end
  end
end