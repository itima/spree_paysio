module Spree
  class PaysioPayment < ActiveRecord::Base
    has_one :payment, :as => :source

    attr_accessor :wallet 
    
    attr_accessible :charge_id, :merchant_id, :object, :order_id, :payment_system_id, :wallet

    validate :charge_id, presence: true
    validate :payment_system_id, presence: true
    # validate :order_id, presence: true

    def success?
      valid?
    end

    def authorization
    end

    def change_payment_state(state)
      status = case state
        when 'paid'
          :complete
        when 'success'
          :complete
        when 'pending'
          :pend
        when 'failure'
          :failure
        when 'refunded'
          :void
        else
          :pend
        end
      payment_object = payment
      payment_object.send(status)
    end

    class << self
      # Public: Creates new charge
      #
      # order       - The Spree::Order object for pay process.
      # params      - The request params object.
      # return_url  - The String represnt url address where Pays.io should return.
      #
      # Returns created Paysio::Charge object.
      def create_charge(order, params, return_url)
        if exists?(order)
          retrieve_charge(paysio_payment.charge_id)
        else
          attributes = {
            amount: "#{order.total.to_i * 100}",
            order_id: "#{order.number}",
            currency_id: 'rur',
            description: "Order ##{order.number}",
            payment_system_id: params[:payment_system_id],
            success_url: return_url,
            failure_url: return_url,
            return_url: return_url
          }

          if params[:wallet].present? && params[:wallet][:account].present?
            attributes[:wallet] = { :account => params[:wallet][:account] }
          end

          begin
            Paysio.api_key = PaymentMethod::PaysioCom.preferences[:client_api_key]
            Paysio::Charge.create(attributes)
          rescue Paysio::Errors::BadRequest => e
            e
          end
        end

      end
      
      # Public: Process recieved charge from paysio.
      #
      # charge_id  - Charge id param .
      #
      # Returns Paysio::Charge object.
      def process_charge(charge_id)
        charge = retrieve_charge(charge_id)

        paysio_payment = find_by_charge_id(charge.id)
        if paysio_payment.present?
          paysio_payment.change_payment_state(charge.status)
        end
        charge
      end

      # Public: Process recieved event from paysio.
      #
      # event_id  - Event id param .
      #
      # Returns Paysio::Event object.
      def process_event(event_id)
        Paysio.api_key = PaymentMethod::PaysioCom.preferences[:client_api_key]
        event = Paysio::Event.retrieve(event_id)
        if event.data.object == 'charge'
          status = case event.type
          when 'charge.success'
            'success'
          when 'charge.failure'
            'failure'
          when 'charge.refund'
            'refunded'
          else
            ''
          end
          paysio_payment = find_by_charge_id(event.data.id)
          if paysio_payment.present?
            paysio_payment.change_payment_state(status)
          end
        end
        event           
      end
    private
      def retrieve_charge(charge_id)
        Paysio.api_key = PaymentMethod::PaysioCom.preferences[:client_api_key]
        Paysio::Charge.retrieve(charge_id)
      end

      # TODO: need to check in paysio charges...
      def exist?(order)
        paysio_payment = find_by_order_id(order.number)
        paysio_payment.present? && paysio_payment.payment_system_id == params[:payment_system_id]
      end
      alias :exists? :exist?
    end
  end
end