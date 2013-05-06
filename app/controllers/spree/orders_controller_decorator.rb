module Spree
  OrdersController.class_eval do 
    before_filter :paysio_redirect

  private
    def paysio_redirect
      if session[:paysio_redirect]
        redirect_to session.delete(:paysio_redirect)
      end
    end
  end
end