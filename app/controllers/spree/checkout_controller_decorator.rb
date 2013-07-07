module Spree
  CheckoutController.class_eval do
    
    before_filter :paysio_checkout if PaymentMethod::PaysioCom.current_method.present?

  private
    def paysio_checkout
      # Move paysio params to params[:payment_source]
      if params[:payment_system_id].present?
        params.merge!(:payment_source => { 
          "#{PaymentMethod::PaysioCom.current_method.id}" => {
            "payment_system_id" => params[:payment_system_id], 
            "wallet" => params[:wallet].present? ? params[:wallet] : ""
          }
        })

        # if paysio was selected 
        if PaymentMethod::PaysioCom.current_method.id.to_s == params[:order][:payments_attributes].first[:payment_method_id]
          @charge = PaysioPayment.create_charge(@order, params, paysio_charges_url)
          if @charge.class == Paysio::Errors::BadRequest
            flash[:error] = @charge.params.first["message"]
            redirect_to cart_path
            return
          else
            if @charge.redirect
              flash[:warn] = "Please visit #{@charge.redirect} to pay your order!"
              session[:paysio_redirect] = @charge.redirect
            end
            if @charge.status == 'paid'
              flash[:error] = t(:order_already_paid)
              redirect_to cart_path
              return
            end
            params[:payment_source]["#{PaymentMethod::PaysioCom.current_method.id}"]["charge_id"] = @charge.id
          end
        end        
      end
      #render text: params.inspect  + @charge.inspect + @charge.params.inspect and return
    end
  end
end