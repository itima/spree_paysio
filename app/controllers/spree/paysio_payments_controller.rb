module Spree
  class PaysioPaymentsController < Spree::StoreController

    def paysio_events
      event = PaysioPayment.process_event(params[:id])
      if Rails.env.development?
        render text: event.to_yaml
      else
        redirect_to root_path
      end
    end

    def paysio_charges
      charge = PaysioPayment.process_charge(params[:charge_id])

      if charge.present? && charge.class == Paysio::Charge
        @order = Order.find_by_number(charge.order_id) if charge.order_id.present?
        @order ||= PaysioPayment.find_by_charge_id(charge.id).payment.order
      end

      if @order.present?
        flash[:notice] = t("order_payment_state", state: t(charge.status))
        redirect_to order_path(@order)
      else
        flash[:error] = t(:invalid_paysio_charge)
        redirect_to root_path
      end
    end
  end
end