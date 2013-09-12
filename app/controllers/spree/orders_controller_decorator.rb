module Spree
  OrdersController.class_eval do 
    before_filter :paysio_redirect

  private
    def paysio_redirect
      if (path = session.delete(:paysio_redirect))
        redirect_to path unless @order.errors.any?
      end
    end
  end
end